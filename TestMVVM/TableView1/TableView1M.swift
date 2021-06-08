
import Foundation
import RxSwift
import RxCocoa

class TableView1M : MvvmM{
    weak var vm:TableView1VM?
    
    var blogs = BehaviorRelay<[Blog]>(value: [])
    var user = BehaviorRelay<User?>(value: nil)
    var color = BehaviorRelay<UIColor?>(value: UIColor.blue)

    func requestData()->PublishSubject<[Blog]>{
        let r = PublishSubject<[Blog]>()
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
            var arr = [Blog]()
            for i:Int64 in 0..<20{
                let blog = Blog()
                blog.id = i+1
                blog.title = "Title " + (i+1).description
                arr.append(blog)
            }
            r.onNext(arr)
        })
        return r
    }
}
