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
    func rotuteToDetail(url: URL)
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol SearchPresentable: Presentable {
    var listener: SearchPresentableListener? { get set }
    var result: BehaviorRelay<[DocsSection]> {get set}
    func loadDataDone()
    
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol SearchListener: class {
    func closeSearchViewController()
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class SearchInteractor: PresentableInteractor<SearchPresentable>, SearchInteractable, SearchPresentableListener {
    
    func didClickItem(url: URL) {
        router?.rotuteToDetail(url: url)
    }
    
    func closeViewController() {
        self.listener?.closeSearchViewController()
    }
    
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
    
    func searchArticles() {
        self.param.asObservable().subscribe(onNext: { (param) in
            if param.keyword.count <= 0 || param.keyword.isEmpty {return}
            ServiceController().searchArticles(keyword: param.keyword, page: param.pageIndex) { [unowned self] (data) in
                self.presenter.loadDataDone()
                guard let value = data?.response.docs else {return}
                self.getData(data: value, pageIndex: param.pageIndex)
            }
        }).disposed(by: bag)
    }
    
    func getData(data: [DocsEntity], pageIndex: Int) {
        self.queue.sync {
            self.group.enter()
            
            if pageIndex == 0 { self.listData.removeAll() }
            
            let itemLoadMore: String = "loadmore"
            if let item = self.listData.last as? String, item.elementsEqual(itemLoadMore) {
                self.listData.removeLast()
            }
            
            self.listData.append(contentsOf: data)
            
            if data.count >= 10 {
                self.listData.append(itemLoadMore)
            }
            self.group.leave()
        }
        
        self.group.notify(queue: .main) {
            let oneSection = DocsSection(items: self.listData)
            self.presenter.result.accept([oneSection])
        }
    }

    override func willResignActive() {
        super.willResignActive()
        
    }
}
