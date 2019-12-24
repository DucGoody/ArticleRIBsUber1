//
//  RootBuilder.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/23/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs

protocol RootDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class RootComponent: Component<RootDependency>, HomeDependency {
    let rootViewController: RootViewController
    init(dependency: RootDependency, rootViewController: RootViewController) {
        self.rootViewController = rootViewController
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

protocol RootBuildable: Buildable {
    func build() -> LaunchRouting
}

final class RootBuilder: Builder<RootDependency>, RootBuildable {

    override init(dependency: RootDependency) {
        super.init(dependency: dependency)
    }

    func build() -> LaunchRouting {
        let vc = RootViewController()
        let component = RootComponent.init(dependency: dependency, rootViewController: vc)
        
        let interactor = RootInteractor.init(presenter: vc)
        let home = HomeBuilder(dependency: component)
        return RootRouter.init(interactor: interactor, viewController: vc, homeBuildable: home)
    }
}
