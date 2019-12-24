//
//  DatePickerRouter.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/24/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs

protocol DatePickerInteractable: Interactable {
    var router: DatePickerRouting? { get set }
    var listener: DatePickerListener? { get set }
}

protocol DatePickerViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DatePickerRouter: ViewableRouter<DatePickerInteractable, DatePickerViewControllable>, DatePickerRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DatePickerInteractable, viewController: DatePickerViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
