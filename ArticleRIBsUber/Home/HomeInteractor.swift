//
//  HomeInteractor.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/23/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa

protocol HomeRouting: ViewableRouting {
    func cleanupViews()
    func rotuteToDetail(url: URL)
    func rotuteToShowDate(viewInput: UIView, date: Date)
    func gotoSearch()
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol HomePresentable: Presentable {
    var listener: HomePresentableListener? { get set }
    var result: BehaviorRelay<[DocsSection]>? {get set}
    func updateView(_ date: Date)
    func loadDataDone(_ isDone: Bool)
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol HomeListener: class {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class HomeInteractor: PresentableInteractor<HomePresentable>, HomeInteractable, HomePresentableListener {
    
    func closeSearchViewController() {
        router?.cleanupViews()
    }
    
    func gotoSearch() {
        self.router?.gotoSearch()
    }
    
    var param: BehaviorRelay<Date>
    weak var router: HomeRouting?
    weak var listener: HomeListener?
    private let bag = DisposeBag()
    
    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: HomePresentable) {
        self.param = BehaviorRelay<Date>.init(value: Date())
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        getLatestArticles()
        // TODO: Implement business logic here.
    }
    
    func didSelectDate(date: Date?) {
        router?.cleanupViews()
        if let date = date {
            presenter.updateView(date)
            presenter.loadDataDone(false)
            param.accept(date)
        }
    }
    
    func getLatestArticles() {
        self.param.subscribe(onNext: { (date) in
            ServiceController().getLatestArticles(date: date) { (response) in
                self.presenter.loadDataDone(true)
                guard let docs = response?.response.docs else {
                    return
                }
                let section = DocsSection(items: docs)
                self.presenter.result?.accept([section])
            }
        }).disposed(by: bag)
    }
    
    func didClickItem(url: URL) {
        router?.rotuteToDetail(url: url)
    }
    
    func didShowDate(viewInput: UIView, date: Date) {
        router?.rotuteToShowDate(viewInput: viewInput, date: date)
    }
    
    override func willResignActive() {
        super.willResignActive()
        router?.cleanupViews()
    }
}
