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
    }

    let usernameWrapper = SubjectWrapper<String>(keyPath: \LoginM.username)
    let passwordWrapper = SubjectWrapper<String>(keyPath: \LoginM.password)
    let isAbcWrapper = SubjectWrapper<Bool>(keyPath: \LoginM.isAbc)
    let birthdayWrapper = SubjectWrapper<Date?>(keyPath: \LoginM.birthday)

    lazy var isBtnEnabled = {
        Observable.combineLatest(usernameWrapper.subject,passwordWrapper.subject) { un, pwd -> Bool in
            return un.count > 0 && pwd.count >= 6
        }
    }()
        
    func prepare(){
        bind(usernameWrapper,ctl: vc!.tf1)
        bind(passwordWrapper,ctl: vc!.tf2)
        bind(isAbcWrapper,ctl: vc!.sw1)
        bind(birthdayWrapper,ctl: vc!.dp1)
        
        isBtnEnabled.debug("isBtnEnabled:", trimOutput: true).bind(to: (vc!.btnLogin.rx.isEnabled)).disposed(by: bag)
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

