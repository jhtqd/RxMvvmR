

import UIKit
import RxSwift
import RxCocoa

class TableView1VM : MvvmVM<TableView1M>{    
    weak var vc:TableView1VC!
    init(vc:TableView1VC,m:TableView1M){
        super.init()
        self.vc = vc
        self.m = m
    }

    let blogsWrapper = SubjectWrapper_Ro<[Blog]>(keyPath: \TableView1M.blogs)
    let userWrapper = SubjectWrapper_Ro<User?>(keyPath: \TableView1M.user)
    let colorWrapper = SubjectWrapper_Ro<UIColor?>(keyPath: \TableView1M.color)
        
    func prepare(){
        bind(userWrapper) { user in
            self.vc.title = user?.name
        }

        bind(colorWrapper, ctl: self.vc.tableView.rx.backgroundColor)
        
        bind_Table(
            blogsWrapper,
            ctl: vc!.tableView,
            cellIdentifier: "Cell",
            cellType: TableView1Cell.self
            ){
            (row,element, cell) in
            cell.setData(blog: element)            
        }
        
        vc.tableView.rx
            .modelSelected(Blog.self)
            .subscribe(onNext: { value in
                print("开始选中====\(value.title)")
            }).disposed(by: bag)
        
        
        
        userWrapper.next(m.user)
        colorWrapper.next(UIColor.green)
    }
}

extension TableView1VM{
    func doRequestBlogs(){
        self.m?.requestData()
            .debug()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] arr in
                    self?.blogsWrapper.next(arr)
                },
                onError: {e in
                    print(e.localizedDescription)
                }
            )
            .disposed(by: bag)
    }
}

