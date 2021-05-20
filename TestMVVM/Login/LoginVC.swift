//
//  ViewController.swift
//  TestMVVM
//
//  Created by jiaohaitao on 2021/5/19.
//

import UIKit
import RxSwift
import RxCocoa


class LoginVC: MvvmBaseUIViewController<LoginVM,LoginM>{
    
    func createMvvm(){
        self.vm = LoginVM(vc:self,m:LoginM())
        vm.m.vm = vm
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createMvvm()
        
        self.vm.prepare()
        self.prepareUI()
    }
    
    func prepareUI(){
        #if DEBUG
        fillDebugData()
        #endif
    }
    
    @IBOutlet weak var sw1: UISwitch!
    @IBOutlet weak var dp1: UIDatePicker!
    @IBOutlet weak var tf1: UITextField!
    @IBOutlet weak var tf2: UITextField!
    @IBOutlet weak var lblErr: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btn2: UIButton!
    
    @IBAction func btnLoginClicked(_ sender: Any){
        vm.doLogin()
    }
    @IBAction func btn2Clicked(_ sender: Any){
        
    }
}

#if DEBUG
extension LoginVC{
    func fillDebugData(){
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.vm.usernameWrapper.next("test")
            self.vm.passwordWrapper.next("123456")
            self.vm.isAbcWrapper.next(true)
            let adate = Date(timeIntervalSince1970: 1000)
            self.vm.birthdayWrapper.next(adate)
        }
    }
}
#endif
