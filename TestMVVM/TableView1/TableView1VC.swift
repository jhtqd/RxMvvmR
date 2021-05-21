
import UIKit
import RxSwift
import RxCocoa


class TableView1VC: MvvmBaseUITableViewController<TableView1VM,TableView1M>{    
    func createMvvm(user:User?){
        guard self.vm == nil else {return}
        self.vm = TableView1VM(vc:self,m:TableView1M())
        vm.m.user = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.vm.prepare()                
        self.vm.doRequestBlogs()
    }
    
    @IBOutlet weak var tv: UITableView!    
}


class TableView1Cell: UITableViewCell{
    
    @IBOutlet weak var lbl1: UILabel!
    
    func setData(blog:Blog){
        lbl1.text = "\(blog.title)"
    }
    
}
