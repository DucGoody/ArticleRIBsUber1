//
//  DatePickerBuilder.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/24/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs

protocol DatePickerDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DatePickerComponent: Component<DatePickerDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DatePickerBuildable: Buildable {
    func build(withListener listener: DatePickerListener, inputView: UIView, dateSelected: Date) -> DatePickerRouting
}

final class DatePickerBuilder: Builder<DatePickerDependency>, DatePickerBuildable {

    override init(dependency: DatePickerDependency) {
        super.init(dependency: dependency)
    }
    
    func build(withListener listener: DatePickerListener, inputView: UIView, dateSelected: Date) -> DatePickerRouting {
        _ = DatePickerComponent(dependency: dependency)
        let viewController = DatePickerViewController.init(dateSelected: dateSelected, viewInput: inputView)
        let interactor = DatePickerInteractor(presenter: viewController)
        interactor.listener = listener
        return DatePickerRouter(interactor: interactor, viewController: viewController)
    }
}
