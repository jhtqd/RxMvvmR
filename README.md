# RxMvvmR （RxSwift MVVM With Router）
此Demo演示了利用RxSwift实现MVVM的一种思路（Router与MVVM无耦合，是可选功能）

# View
  即各个 ViewController；UI设计、控件关联、事件关联，采取了Storyboard（个人认为，比直接用RxSwift去关联事件要方便）  
  ViewController内，定义了：  
  1.控件引用  
  2.控件事件响应入口（然后再把调用转给VM处理）  
  3.创建 M，V，VM三大对象，并设置三者之间的相互引用关联  
# Model
  即要操作的数据，内部定义了：  
  1.数据属性，例如：用户姓名，年龄等等  
  2.存取数据的方法：例如从磁盘、数据库、网络读取数据；保存数据到各种地方，等等。  
  与服务器的所有网络交互，包括数据打包和解析代码，放在Model里也是可以的（上行和下行的所有东西，都可以当做是数据传递）  
  注：Model != Entity，不要混淆二者的定义
```swift
    struct User{...}   //这是Entity
    class NewBlogModel : XxxBaseModel{ 
      var user:User?
      var content:String = ""
      var tags:[String] = []
      ....
    }
```    
# ViewModel
  ViewModel是核心，实现了与View，与Model的双向绑定  
     
  View <-----  ViewModel -----> Model  
  通过ViewModel设置新值后，View自动更新，Model自动更新  
             
  View ----->  ViewModel -----> Model  
  View数据被用户修改后，自动通过ViewModel同步到Model  
  
  本方案里，直接修改Model不会自动同步到ViewModel和View；Model里都是属性，如果每个属性添加didSet，会导致model变得复杂，故此方案保持Model的简洁。  
  修改Model数据有两个方法：  
  1.修改Model，然后调用ViewModel的 reload(wrapper),修改哪个属性，对应的wrapper就要reload一下  
  2.直接调用wrapper.next(新值)，调用后，View和Model均自动更新  

        
  主要定义了：  
  1.各个属性的连接点的定义：连接点既是Observable，又是Ovserver，默认采用的是PublishSubject；  
  同时，为了使用方便，对连接点进行了包装：SubjectWrapper<T>,这个包装既包含Subject，又包含属性的  KeyPath  
  2.连接点的绑定：绑定后，双向同步即可正常工作  
  3.连接点更多绑定：例如：密码输入6位以上，登录按钮才变为可用，此时，密码的连接点需要更多的绑定，用以更新登录按钮  
  4.业务逻辑的处理（网络交互部分转给Model处理）  
  
# Code Example
  基类封装了一些细节，业务中实际使用的类并不复杂，此处忽略部分无关代码。  
  Model样例：
```swift
class LoginM : MvvmM{
    weak var vm:LoginVM?

    var username:String = ""
    var password:String = ""
        
    func requestLogin()->PublishSubject<User>{
        let r = PublishSubject<User>()
        print("模拟登录中。。预计耗时0.3秒");
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3, execute: {
            print("模拟登录完成");
            let u = User()
            u.id = 1
            u.name = "张三"
            r.onNext(u)
        })
        return r
    }
}
```
View样例：
```swift  
class LoginVC: MvvmBaseUIViewController<LoginVM,LoginM>{    
    func createMvvm(){
        self.vm = LoginVM(vc:self,m:LoginM())
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createMvvm()
  
        self.vm.prepare()
    }
    
    
    @IBOutlet weak var tf1: UITextField!
    @IBOutlet weak var tf2: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBAction func btnLoginClicked(_ sender: Any){
        vm.doLogin()
    }
}
```
ViewModel样例：
```swift  
  class LoginVM : MvvmVM<LoginM>{
    weak var vc:LoginVC!   
  
    init(vc:LoginVC,m:LoginM){
        super.init()
        self.vc = vc
        self.m = m
        self.m.vm = self
    }

    let usernameWrapper = SubjectWrapper<String>(keyPath: \LoginM.username)
    let passwordWrapper = SubjectWrapper<String>(keyPath: \LoginM.password)
    lazy var isBtnEnabled = {
        Observable.combineLatest(usernameWrapper.subject,passwordWrapper.subject) { un, pwd -> Bool in
            return un.count > 0 && pwd.count >= 6
        }
    }()
        
    func prepare(){
        bind(usernameWrapper,ctl: vc!.tf1)
        bind(passwordWrapper,ctl: vc!.tf2)
        isBtnEnabled.bind(to: (vc!.btnLogin.rx.isEnabled)).disposed(by: bag)
    }
}

extension LoginVM{
    func doLogin(){
        m?.requestLogin()
            .debug()
            .observe(on: MainScheduler.instance)
           .subscribe(
                onNext: {[weak self] u in
                    MvvmRouter.showTableView1VC(fromVC: self?.vc, user: u)
                }
            )
            .disposed(by: bag)
    }
}
```

