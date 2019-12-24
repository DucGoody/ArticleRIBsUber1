//
//  SearchViewController.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/24/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa
import SnapKit
import RxDataSources
import UIKit

protocol SearchPresentableListener: class {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var param: BehaviorRelay<ParamSearchArticles>{get set}
    func didClickItem(url: URL)
    func closeViewController()
}

final class SearchViewController: UIViewController, SearchPresentable, SearchViewControllable {
    var result: BehaviorRelay<[DocsSection]>
    
    func loadDataDone() {
        refreshControl.endRefreshing()
        indicator.isHidden = true
    }

    @IBOutlet weak var tableView: UITableView!
    weak var listener: SearchPresentableListener?
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    private let articleCellName: String = "ArticleCell"
    private let loadMoreCell: String = "LoadMoreCell"
    private let bag = DisposeBag()
    private var indicator: UIActivityIndicatorView!
    private let param: ParamSearchArticles = ParamSearchArticles()
    private let refreshControl = UIRefreshControl()
    
    init() {
        self.result = BehaviorRelay<[DocsSection]>.init(value: [])
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib.init(nibName: articleCellName, bundle: nil), forCellReuseIdentifier: articleCellName)
        tableView.register(UINib.init(nibName: loadMoreCell, bundle: nil), forCellReuseIdentifier: loadMoreCell)
        tableView.separatorColor = .clear
        tableView.contentInset = UIEdgeInsets.init(top: 16, left: 0, bottom: 16, right: 0)
        
        indicator = UIActivityIndicatorView.init()
        self.view.addSubview(indicator)
        indicator.snp.makeConstraints { (tbl) in
            tbl.center.equalTo(self.view)
        }
        indicator.startAnimating()
        indicator.isHidden = true
        tableView.delegate = self
        
        searchTextField.becomeFirstResponder()
        searchTextField.rx.controlEvent([.editingChanged]).asObservable().throttle(1000, scheduler: MainScheduler.instance).subscribe(onNext: { [unowned self](_) in
            self.indicator.isHidden = false
            self.onSearch()
        }).disposed(by: bag)
        
        cancelButton.rx.tap.asDriver().throttle(1000).drive(onNext: { [unowned self](_) in
            self.listener?.closeViewController()
        }).disposed(by: bag)
        
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshControl.tintColor = UIColor.lightGray
    
        onClickItem()
        binData()
    }
    
    // action pulltorefresh
    @objc private func refreshData() {
        param.pageIndex = 0
        self.listener?.param.accept(param)
    }
    
    func binData() {
        result.asObservable().bind(to: tableView.rx.items(dataSource: dataSource())).disposed(by: bag)
    }
    
    func onClickItem() {
        tableView.rx.modelSelected(DocsEntity.self).throttle(1, scheduler: MainScheduler.instance).subscribe(onNext: {[unowned self] entity in
            guard let url = URL.init(string: entity.webUrl) else {return}
            self.listener?.didClickItem(url: url)
        }).disposed(by: bag)
    }
    
    func onSearch() {
        if let text = searchTextField.text, !text.isEmpty, text.count > 0 {
            param.keyword = text
            param.pageIndex = 0
            self.listener?.param.accept(param)
        }
    }
    
    // get cell article
    func getArticlesCell(item: DocsEntity) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: articleCellName) as? ArticleCell {
            cell.binData(docs: item)
            return cell
        }
        return UITableViewCell()
    }
    
    //get cell load more
    func getLoadMoreCell() -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: loadMoreCell) as? LoadMoreCell {
            cell.indicator.startAnimating()
            return cell
        }
        return UITableViewCell()
    }
}

extension SearchViewController : UITableViewDelegate {
    // action load more
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let arrCellName = NSStringFromClass(cell.classForCoder).components(separatedBy: ".")
        if loadMoreCell.elementsEqual(arrCellName.last ?? "") {
            param.pageIndex += 1
            self.listener?.param.accept(param)
        }
    }
}

extension SearchViewController {
    //init data source
    func dataSource() -> RxTableViewSectionedReloadDataSource<DocsSection> {
        return RxTableViewSectionedReloadDataSource<DocsSection>(
            configureCell: { dataSource, table, indexPath, item in
                if let item = item as? DocsEntity {
                    return self.getArticlesCell(item: item)
                } else {
                    return self.getLoadMoreCell()
                }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func replaceModal(vc: ViewControllable?) {
        guard let vc = vc else { return }
        self.navigationController?.pushViewController(vc.uiviewController, animated: true)
    }
}

class ParamSearchArticles: NSObject {
    var keyword: String = ""
    var pageIndex: Int = 0
}
