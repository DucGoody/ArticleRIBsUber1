//
//  HomeViewController.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/23/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa
import SnapKit
import UIKit
import RxDataSources

protocol HomePresentableListener: class {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var param: BehaviorRelay<Date>{get set}
    func didClickItem(url: URL)
    func didShowDate(viewInput: UIView, date: Date)
    func gotoSearch()
}

final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {
        
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var result: BehaviorRelay<[DocsSection]>?
    weak var listener: HomePresentableListener?
    private var indicator: UIActivityIndicatorView!
    private let articleCellName: String = "ArticleCell"
    private let bag = DisposeBag()
    private var dateSelect: Date = Date()
    
    init() {
        self.result = BehaviorRelay<[DocsSection]>.init(value: [])
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "New Youk Times"
        let imageSearch = UIImage.init(named: "ic_search")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: imageSearch, style: .plain, target: self, action:#selector(clickRightNavigation))
        
        initUI()
        binData()
        onClickItem()
    }
    
    func updateView(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let dateString = formatter.string(from: date)
        dateLabel.text = dateString
    }
    
    func loadDataDone(_ isDone: Bool) {
        indicator.isHidden = isDone
    }
    
    func initUI() {
        tableView.register(UINib.init(nibName: articleCellName, bundle: nil), forCellReuseIdentifier: articleCellName)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = .clear
        tableView.backgroundColor = .systemGroupedBackground
        
        indicator = UIActivityIndicatorView.init()
        self.view.addSubview(indicator)
        indicator.snp.makeConstraints { (tbl) in
            tbl.center.equalTo(self.view)
        }
        indicator.startAnimating()
        
        dateView.layer.cornerRadius = 5
        dateView.layer.borderWidth = 0.5
        dateView.layer.borderColor = UIColor.gray.cgColor
        
        self.dateButton.rx.tap.asDriver()
        .throttle(1000)
        .drive(onNext: { [unowned self] (_) in
             self.listener?.didShowDate(viewInput: self.dateView, date: self.dateSelect)
        }).disposed(by: bag)
    }
    
    //click button search
    @objc func clickRightNavigation() {
        self.listener?.gotoSearch()
    }
    
    //bin data tableView
    func binData() {
        result?.asObservable().bind(to: tableView.rx.items(dataSource: dataSource())).disposed(by: bag)
    }
    
    //onClick item
    func onClickItem() {
        tableView.rx.modelSelected(DocsEntity.self).throttle(1, scheduler: MainScheduler.instance).subscribe(onNext: {[unowned self] entity in
            guard let url = URL.init(string: entity.webUrl) else {return}
            self.listener?.didClickItem(url: url)
        }).disposed(by: bag)
    }
    
    // get cell article
    func getArticlesCell(item: DocsEntity) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: articleCellName) as? ArticleCell {
            cell.binData(docs: item)
            return cell
        }
        return UITableViewCell()
    }
    
    // replace viewcontroller
    func replaceModal(vc: ViewControllable?, isPresent: Bool) {
        guard let vc = vc else { // == nil
            if presentedViewController != nil {
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
            return
        }
        // present hay k
        if isPresent {
            vc.uiviewController.modalPresentationStyle = .overCurrentContext
            self.present(vc.uiviewController, animated: false, completion: nil)
        } else {
            self.navigationController?.pushViewController(vc.uiviewController, animated: true)
        }
    }
}

extension HomeViewController {
    //init data source
    func dataSource() -> RxTableViewSectionedReloadDataSource<DocsSection> {
        return RxTableViewSectionedReloadDataSource<DocsSection>(
            configureCell: { dataSource, table, indexPath, item in
                if let item = item as? DocsEntity {
                    return self.getArticlesCell(item: item)
                }
               return UITableViewCell()
        })
    }
}


struct DocsSection {
    var items: [Any]
}

extension DocsSection: SectionModelType {
    typealias Item = Any
    init(original: DocsSection, items: [Item]) {
        self = original
        self.items = items
    }
}

