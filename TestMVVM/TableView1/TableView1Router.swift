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
    static func showTableView1VC(fromVC:UIViewController?,user:User?){
        let vcraw = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TableView1VC")
        let vc = vcraw as! TableView1VC
        vc.createMvvm(user: user)
        fromVC?.showVCAuto(vc: vc)
    }
    
}
