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
    func replaceModal(vc: ViewControllable?, isPresent: Bool)
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable>, HomeRouting {
    
    func gotoSearch() {
        let detail = searchBuildable.build(withListener: interactor)
        attachChild(detail)
        currentChild = detail
        viewController.replaceModal(vc: detail.viewControllable, isPresent: false)
    }
    
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
    
    func rotuteToDetail(url: URL) {
        let detail = detailBuildable.build(withListener: interactor, url: url)
        attachChild(detail)
        currentChild = detail
        viewController.replaceModal(vc: detail.viewControllable, isPresent: false)
    }
    
    func rotuteToShowDate(viewInput: UIView, date: Date) {
        let dateBuildable = datePickerBuildable.build(withListener: interactor, inputView: viewInput, dateSelected: date)
        attachChild(dateBuildable)
        currentChild = dateBuildable
        viewController.replaceModal(vc: dateBuildable.viewControllable, isPresent: true)
    }
    
    func cleanupViews() {
        viewController.replaceModal(vc: nil, isPresent: false)
    }
}
