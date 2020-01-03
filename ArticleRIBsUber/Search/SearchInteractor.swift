//
//  SearchInteractor.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/24/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa

protocol SearchRouting: ViewableRouting {
    // chuyển sang màn hình chi tiết
    func rotuteToDetail(url: URL)
}

protocol SearchPresentable: Presentable {
    var listener: SearchPresentableListener? { get set }
    // result khi search
    var result: BehaviorRelay<[DocsSection]> {get set}
    //load data done
    func loadDataDone()
    
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol SearchListener: class {
    func closeSearchViewController()
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class SearchInteractor: PresentableInteractor<SearchPresentable>, SearchInteractable, SearchPresentableListener {
    
    var param: BehaviorRelay<ParamSearchArticles>
    weak var router: SearchRouting?
    weak var listener: SearchListener?
    private let bag = DisposeBag()
    private let group = DispatchGroup()
    private let queue = DispatchQueue.global(qos: .background)
    private var listData: [Any] = []

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: SearchPresentable) {
        param = BehaviorRelay<ParamSearchArticles>.init(value: ParamSearchArticles())
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        searchArticles()
    }
    
    // chọn item
    func didClickItem(url: URL) {
        router?.rotuteToDetail(url: url)
    }
    
    // close viewcontroller
    func closeViewController() {
        listener?.closeSearchViewController()
    }
    
    // search articels
    func searchArticles() {
        param.asObservable().subscribe(onNext: { (param) in
            if param.keyword.count <= 0 || param.keyword.isEmpty {return}
            ServiceController().searchArticles(keyword: param.keyword, page: param.pageIndex) { [unowned self] (data) in
                self.presenter.loadDataDone()
                guard let value = data?.response?.docs else {return}
                self.getData(data: value, pageIndex: param.pageIndex)
            }
        }).disposed(by: bag)
    }
    
    //get data -> add item load more
    func getData(data: [DocsEntity], pageIndex: Int) {
        queue.sync {
            group.enter()
            
            if pageIndex == 0 { listData.removeAll() }
            
            let itemLoadMore: String = "loadmore"
            if let item = listData.last as? String, item.elementsEqual(itemLoadMore) {
                listData.removeLast()
            }
            
            listData.append(contentsOf: data)
            
            if data.count >= 10 {
                listData.append(itemLoadMore)
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            let oneSection = DocsSection(items: self.listData)
            self.presenter.result.accept([oneSection])
        }
    }

    override func willResignActive() {
        super.willResignActive()
        
    }
}
