//
//  LoginViewModel.swift
//  TestMVVM
//
//  Created by jiaohaitao on 2021/5/19.
//

import UIKit
import RxSwift
import RxCocoa

open class MvvmVM<TypeM>{
    var m:TypeM!
    
    let bag:DisposeBag = DisposeBag()
    
    public func reload<ValueType>(_ wrapper:SubjectWrapper_Ro<ValueType>){
        wrapper.current(self)
    }
    public func reload<ValueType>(_ wrapper:SubjectWrapper<ValueType>){
        wrapper.current(self)
    }

    open class SubjectWrapper<ValueType>{
        var subject = PublishSubject<ValueType>()
        let keyPath:WritableKeyPath<TypeM,ValueType>
        
        init(keyPath:WritableKeyPath<TypeM,ValueType>){
            self.keyPath = keyPath
        }
        func next(_ v:ValueType){
            self.subject.onNext(v)
        }
        func current(_ vm:MvvmVM<TypeM>){
            let v = vm.m![keyPath: keyPath]
            self.subject.onNext(v)
        }
    }
    
    open class SubjectWrapper_Ro<ValueType>{
        var subject = PublishSubject<ValueType>()
        let keyPath:WritableKeyPath<TypeM,ValueType>
        
        init(keyPath:WritableKeyPath<TypeM,ValueType>){
            self.keyPath = keyPath
        }
        func next(_ v:ValueType){
            self.subject.onNext(v)
        }
        func current(_ vm:MvvmVM<TypeM>){
            let v = vm.m![keyPath: keyPath]
            self.subject.onNext(v)
        }
    }
}

extension MvvmVM {
    // 单向绑定：
    // View <-----  ViewModel -----> Model
    // 通过ViewModel设置新值后，View自动更新，Model自动更新
    // 但View数据不能更改，也就不能通过ViewModel同步到Model

    func bind<ValueType>(_ wrapper:SubjectWrapper_Ro<ValueType>,bindFunc:((ValueType)->Void)?){
        wrapper.subject.debug().subscribe(onNext: { s in
            self.m?[keyPath:wrapper.keyPath] = s
        }).disposed(by: bag)
        wrapper.subject.subscribe(onNext: bindFunc).disposed(by: bag)
        wrapper.current(self)
    }

    func bind<ValueType>(_ wrapper:SubjectWrapper_Ro<ValueType>,ctl:Binder<ValueType>){
        wrapper.subject.debug().subscribe(onNext: { s in
            self.m?[keyPath:wrapper.keyPath] = s
        }).disposed(by: bag)
        wrapper.subject.bind(to: ctl).disposed(by: bag)
        wrapper.current(self)
    }

    func bind_Table<ItemType,CellType:UITableViewCell>(
        _ wrapper: SubjectWrapper_Ro<[ItemType]>,
        ctl: UITableView,
        cellIdentifier: String,
        cellType: CellType.Type,
        cellfunc: @escaping (Int,ItemType,CellType)->Void){
        
        ctl.delegate = nil
        ctl.dataSource = nil
        
        wrapper.subject
            .debug()
            .subscribe(onNext: { s in
            self.m?[keyPath:wrapper.keyPath] = s
        }).disposed(by: bag)
        
        wrapper.subject.bind(to: ctl.rx.items(cellIdentifier: cellIdentifier, cellType: cellType)){
            (row,element, cell) in
            cellfunc(row,element, cell)
        }
        .disposed(by: bag)
        wrapper.current(self)
    }
}

extension MvvmVM {
    /**
     双向绑定：
     
        View <-----  ViewModel -----> Model
        通过ViewModel设置新值后，View自动更新，Model自动更新
             
        V iew ----->  ViewModel -----> Model
        View数据被用户修改后，自动通过ViewModel同步到Model
     */

    func bind(_ wrapper:SubjectWrapper<String>,ctl:UITextField){
        wrapper.subject.debug().subscribe(onNext: { s in
            self.m?[keyPath:wrapper.keyPath] = s
        }).disposed(by: bag)
        wrapper.subject.bind(to: ctl.rx.text).disposed(by: bag)
        wrapper.current(self)
        ctl.rx.text.orEmpty.bind(to:wrapper.subject).disposed(by: bag)
    }
    
    func bind(_ wrapper:SubjectWrapper<String>,ctl:UITextView){
        wrapper.subject.debug().subscribe(onNext: { s in
            self.m?[keyPath:wrapper.keyPath] = s
        }).disposed(by: bag)
        wrapper.subject.bind(to: ctl.rx.text).disposed(by: bag)
        wrapper.current(self)
        ctl.rx.text.orEmpty.bind(to:wrapper.subject).disposed(by: bag)
    }

    func bind(_ wrapper:SubjectWrapper<Bool>,ctl:UISwitch){
        wrapper.subject.debug().subscribe(onNext: { s in
            self.m?[keyPath:wrapper.keyPath] = s
        }).disposed(by: bag)
        wrapper.subject.bind(to: ctl.rx.isOn).disposed(by: bag)
        wrapper.current(self)
        ctl.rx.isOn.bind(to:wrapper.subject).disposed(by: bag)
    }
    
    func bind(_ wrapper:SubjectWrapper<Date?>,ctl:UIDatePicker){
        wrapper.subject.debug().subscribe(onNext: { s in
            self.m?[keyPath:wrapper.keyPath] = s
        }).disposed(by: bag)
        wrapper.subject.bind { d in
            guard d != nil else{return}
            ctl.rx.date.onNext(d!)
        }.disposed(by: bag)
        wrapper.current(self)
        ctl.rx.date.bind(to: wrapper.subject).disposed(by: bag)
    }
    
}


