# RxMvvmR （RxSwift MVVM With Router）
此Demo演示了利用RxSwift实现MVVM的一种思路（Router与MVVM无耦合，是可选功能）
本方案的目的是实现一个简洁，易维护的MVVM，在简单与解耦之间取得一个平衡点。
在不显著增加文件数量和代码行数的前提下实现MVVM。
为了实现这一目的，对复用代码封装为基类或工具类，复杂性包裹起来，日常工作就变得轻松起来。
此外，此方案与MVC是可以共存的，MVVM是在VC的控制之下工作的，A控件和A属性可以用MVVM绑定，B控件和B属性则完全可以采用原有的MVC模式。
方案的核心当然是RxSwift，个人认为反应式开发模式是MVVM的最佳方案。  
而与之相对比，基于 protocol、delegate 的MVVM、MVP、VIPER模式，增加的琐碎的接口和对象数量，以及胶水代码数量，可能会大大超过有效业务代码数量，给人一种“为了解耦而解耦”的感觉，部分的违背了初衷。  
  
此方案，并非完整的开箱即用的方案，而是一种尝试和思路。方案的难点在于基类的封装，但方案的优点之一是前面提到的MVC兼容，这样就不会阻塞开发进度。  
对老版本的改造也变得更灵活，一个VC里，一部分控件改为MVVM，另一部分下个版本改都是可以的。

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
# Router
  Router是简单的extension扩展，并未采用url模式的路由  
  每个VC都定义如何显示自己的路由方法，提供给其他VC模块使用  
  注：有的路由方案是把VC要跳转其他VC的方法放在自己的路由对象里，供自己使用，与本方案是不同的  
  
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
  
Router样例：
```swift  
  extension MvvmRouter{    
    static func showTableView1VC(fromVC:UIViewController?,user:User?){
        let vcraw = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TableView1VC")
        let vc = vcraw as! TableView1VC
        vc.createMvvm(user: user)
        fromVC?.showVCAuto(vc: vc)
    }    
}
```

