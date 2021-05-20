//
//  ViewController.swift
//  TestMVVM
//
//  Created by jiaohaitao on 2021/5/19.
//

import UIKit
import RxSwift
import RxCocoa

extension MvvmRouter{
    
    static func showLoginVC(fromVC:UIViewController?){
        let vcraw = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginVC")
        let vc = vcraw as! LoginVC
        vc.createMvvm()
        fromVC?.showVCAuto(vc: vc)
    }
    
    
}
