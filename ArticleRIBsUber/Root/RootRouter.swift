//
//  RootRouter.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/23/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs

protocol RootInteractable: Interactable, HomeListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {
    func replaceModal(vc: ViewControllable?)
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
    private let homeBuildable: HomeBuildable
    
    init(interactor: RootInteractable,
         viewController: RootViewControllable,
         homeBuildable: HomeBuildable) {
        self.homeBuildable = homeBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    override func didLoad() {
        super.didLoad()
        self.routeToHome()
    }
    
    private func routeToHome() {
        let home = homeBuildable.build(withListener: interactor)
        attachChild(home)
        let nav = UINavigationController.init(root: home.viewControllable)
        viewController.replaceModal(vc: nav)
    }
}
