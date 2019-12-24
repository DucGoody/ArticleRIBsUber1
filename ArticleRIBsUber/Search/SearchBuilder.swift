//
//  SearchBuilder.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/24/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs

protocol SearchDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class SearchComponent: Component<SearchDependency>, DetailDependency {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol SearchBuildable: Buildable {
    func build(withListener listener: SearchListener) -> SearchRouting
}

final class SearchBuilder: Builder<SearchDependency>, SearchBuildable {

    override init(dependency: SearchDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: SearchListener) -> SearchRouting {
        let component = SearchComponent(dependency: dependency)
        let viewController = SearchViewController()
        let interactor = SearchInteractor(presenter: viewController)
        interactor.listener = listener
        
        let detailBuilable = DetailBuilder.init(dependency: component)
        
        return SearchRouter(interactor: interactor, viewController: viewController, detailBuildable: detailBuilable)
    }
}
