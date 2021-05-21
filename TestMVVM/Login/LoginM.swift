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

    var username:String = "test_user load from local"
    var password:String = "123456"
    var isAbc:Bool = false
    var birthday:Date? = Date()
        
    func requestLogin()->PublishSubject<User>{
        let r = PublishSubject<User>()
        print("模拟登录中。。预计耗时0.01秒");
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01, execute: {
            print("模拟登录完成");
            let u = User()
            u.id = 1
            u.name = "jht"
            r.onNext(u)
        })
        return r
    }
}
