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

    var test = BehaviorRelay<String>(value: "")
    
    var username = BehaviorRelay<String>(value: "test_user")
    var password = BehaviorRelay<String>(value: "123456")
    var isAbc = BehaviorRelay<Bool>(value: false)
    var birthday = BehaviorRelay<Date>(value: Date())
    
        
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
