

import UIKit
import RxSwift
import RxCocoa

class TableView1VM : MvvmVM<TableView1M>{
    weak var vc:TableView1VC!
    init(vc:TableView1VC,m:TableView1M){
        super.init()
        self.vc = vc
        self.m = m
        self.m.vm = self
    }
    
    func prepare(){
        
        _ = vc!.tableView.rx.backgroundColor <-- m.color
        
        vc!.tableView.delegate = nil
        vc!.tableView.dataSource = nil
        
        m.blogs.bind(to: vc!.tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)){ (row, element, cell) in
            cell.textLabel?.text = "\(element.title)"
        }.disposed(by: bag)
        
        vc!.tableView.rx.modelSelected(Blog.self).subscribe(onNext: {
            print("tap index: \($0)")
        }).disposed(by: bag)

    }
}

extension TableView1VM{
    func doRequestBlogs(){
        self.m?.requestData()
            .debug()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] arr in
                    self?.m.blogs.accept(arr)
                },
                onError: {e in
                    print(e.localizedDescription)
                }
            )
            .disposed(by: bag)
    }
}

