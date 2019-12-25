//
//  DatePickerInteractor.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/24/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs
import RxSwift

protocol DatePickerRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DatePickerPresentable: Presentable {
    var listener: DatePickerPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol DatePickerListener: class {
    //select date done
    func didSelectDate(date: Date?)
}

final class DatePickerInteractor: PresentableInteractor<DatePickerPresentable>, DatePickerInteractable, DatePickerPresentableListener {
    
    weak var router: DatePickerRouting?
    weak var listener: DatePickerListener?
    
    func onSelectDate(date: Date?) {
        self.listener?.didSelectDate(date: date)
    }
    
    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: DatePickerPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
}
