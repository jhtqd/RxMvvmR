//
//  LoginViewModel.swift
//  TestMVVM
//
//  Created by jiaohaitao on 2021/5/19.
//

import UIKit
import RxSwift
import RxCocoa


class LoginVM : MvvmVM<LoginM>{
    weak var vc:LoginVC!    
    init(vc:LoginVC,m:LoginM){
        super.init()
        self.vc = vc
        self.m = m
        self.m.vm = self        
    }
    
    var isBtnEnabled : Observable<Bool>?
    
    func prepare(){
        _ = vc!.tf.rx.textInput <->  m.test
        _ = vc!.tf1.rx.textInput <->  m.username
        _ = vc!.tf2.rx.textInput <->  m.password
        _ = vc!.sw1.rx.isOn <->  m.isAbc
        _ = vc!.dp1.rx.date <->  m.birthday

        isBtnEnabled = Observable.combineLatest(m.username,m.password) { un, pwd -> Bool in
                        return un.count > 0 && pwd.count >= 6
                    }
        
        isBtnEnabled?.debug().bind(to: (vc!.btnLogin.rx.isEnabled)).disposed(by: bag)

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
    func doBtn2(){
        m.test.accept("abc")
    }
}

