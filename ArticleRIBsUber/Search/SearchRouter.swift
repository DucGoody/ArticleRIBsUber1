//
//  SearchRouter.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/24/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs

protocol SearchInteractable: Interactable, DetailListener {
    var router: SearchRouting? { get set }
    var listener: SearchListener? { get set }
}

protocol SearchViewControllable: ViewControllable {
    func replaceModal(vc: ViewControllable?)
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class SearchRouter: ViewableRouter<SearchInteractable, SearchViewControllable>, SearchRouting {
    
    private let detailBuildable: DetailBuildable
    
    func rotuteToDetail(url: URL) {
        let detail = detailBuildable.build(withListener: interactor, url: url)
        attachChild(detail)
        viewController.replaceModal(vc: detail.viewControllable)
    }
    

    // TODO: Constructor inject child builder protocols to allow building children.
    init(interactor: SearchInteractable, viewController: SearchViewControllable, detailBuildable: DetailBuildable)
    {
        self.detailBuildable = detailBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

}
