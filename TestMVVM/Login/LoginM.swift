//
//  LoginModel.swift
//  TestMVVM
//
//  Created by jiaohaitao on 2021/5/19.
//

import Foundation
import RxSwift
import RxCocoa


class LoginM : MvvmM{
    weak var vm:LoginVM?

    var username:String = ""
    var password:String = ""
    var isAbc:Bool = false
    var birthday:Date?
        
    func requestLogin()->PublishSubject<User>{
        let r = PublishSubject<User>()
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            let u = User()
            u.id = 1
            u.name = "jht"
            r.onNext(u)
        })
        return r
    }
}
