//
//  HomeRouter.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/23/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs

protocol HomeInteractable: Interactable, DetailListener, DatePickerListener, SearchListener {
    var router: HomeRouting? { get set }
    var listener: HomeListener? { get set }
}

protocol HomeViewControllable: ViewControllable {
    //chuyển sang màn hình mới
    func replaceModal(vc: ViewControllable?, isPresent: Bool)
}

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable>, HomeRouting {
    
    private let detailBuildable: DetailBuildable
    private let searchBuildable: SearchBuildable
    private let datePickerBuildable: DatePickerBuildable
    private var currentChild: ViewableRouting?
    // TODO: Constructor inject child builder protocols to allow building children.
    
    init(interactor: HomeInteractable,
         viewController: HomeViewControllable,
         detailBuildable: DetailBuildable,
         datePickerBuildable: DatePickerBuildable
        , searchBuildable: SearchBuildable) {
        self.detailBuildable = detailBuildable
        self.datePickerBuildable = datePickerBuildable
        self.searchBuildable = searchBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    //chuyển sang màn hình tìm kiếm
    func gotoSearch() {
        let detail = searchBuildable.build(withListener: interactor)
        attachChild(detail)
        currentChild = detail
        viewController.replaceModal(vc: detail.viewControllable, isPresent: false)
    }
    
    //chuyển sang màn hình chi tiết
    func rotuteToDetail(url: URL) {
        let detail = detailBuildable.build(withListener: interactor, url: url)
        attachChild(detail)
        currentChild = detail
        viewController.replaceModal(vc: detail.viewControllable, isPresent: false)
    }
    
    // chuyển sang popup show date
    func rotuteToShowDate(viewInput: UIView, date: Date) {
        let dateBuildable = datePickerBuildable.build(withListener: interactor, inputView: viewInput, dateSelected: date)
        attachChild(dateBuildable)
        currentChild = dateBuildable
        viewController.replaceModal(vc: dateBuildable.viewControllable, isPresent: true)
    }
    
    // close current view
    func cleanupViews() {
        viewController.replaceModal(vc: nil, isPresent: false)
    }
}
