//
//  ViewController.swift
//  TestMVVM
//
//  Created by jiaohaitao on 2021/5/19.
//

import UIKit
import RxSwift
import RxCocoa


open class MvvmBaseUITableViewController<TypeVM,TypeM>: UITableViewController{
    let bag = DisposeBag()
    
    var vm: TypeVM!
}

