//
//  HomeBuilder.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/23/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs

protocol HomeDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class HomeComponent: Component<HomeDependency>, DetailDependency, DatePickerDependency, SearchDependency {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol HomeBuildable: Buildable {
    func build(withListener listener: HomeListener) -> HomeRouting
}

final class HomeBuilder: Builder<HomeDependency>, HomeBuildable {

    override init(dependency: HomeDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: HomeListener) -> HomeRouting {
        let component = HomeComponent(dependency: dependency)
        let viewController = HomeViewController()
        let interactor = HomeInteractor(presenter: viewController)
        interactor.listener = listener
        
        let detailBuildable = DetailBuilder.init(dependency: component)
        let dateBuilable = DatePickerBuilder.init(dependency: component)
        let searchBuilable = SearchBuilder.init(dependency: component)
        return HomeRouter(interactor: interactor, viewController: viewController, detailBuildable: detailBuildable, datePickerBuildable: dateBuilable, searchBuildable: searchBuilable)
    }
}
