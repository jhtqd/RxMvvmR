//
//  ViewController.swift
//  TestMVVM
//
//  Created by jiaohaitao on 2021/5/19.
//

import UIKit

open class MvvmRouter {
    
}

extension UIViewController{
    func showVCAuto(vc:UIViewController){
        if self.navigationController != nil{
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            self.present(vc, animated: true, completion: nil)
        }
    }
}
