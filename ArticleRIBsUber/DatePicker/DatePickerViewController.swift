//
//  DatePickerViewController.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/24/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa
import SnapKit
import MonthYearPicker
import UIKit

protocol DatePickerPresentableListener: class {
    func onSelectDate(date: Date?)
}

final class DatePickerViewController: UIViewController, DatePickerPresentable, DatePickerViewControllable {
    @IBOutlet weak var backgroundView: UIControl!
    private var dateContentView: UIView!
    private var doneButton: UIButton!
    private var picker: MonthYearPickerView!
    
    private let bag = DisposeBag()
    private var viewInput: UIView = UIView()
    private var dateSelected: Date = Date()
    weak var listener: DatePickerPresentableListener?
    
    init(dateSelected: Date, viewInput: UIView) {
        super.init(nibName: "DatePickerViewController", bundle: nil)
        self.dateSelected = dateSelected
        self.viewInput = viewInput
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    //init ui
    func initUI() {
        let originY = self.viewInput.frame.origin.y + viewInput.frame.size.height
        dateContentView = UIView()
        dateContentView.backgroundColor = .white
        dateContentView.layer.cornerRadius = 5
        backgroundView.addSubview(self.dateContentView)
        dateContentView.snp.makeConstraints { (view) in
            view.height.equalTo(200)
            view.left.right.equalTo(self.view).inset(16)
            view.top.equalTo(self.view).inset(originY)
        }
        self.addShadow(view: self.dateContentView)
        
        //button done
        self.doneButton = UIButton()
        self.doneButton.setTitle("Xong", for: .normal)
        self.doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.doneButton.setTitleColor(.white, for: .normal)
        self.doneButton.layer.cornerRadius = 5
        self.doneButton.backgroundColor = UIColor.link
        self.doneButton.rx.tap.asDriver()
        .throttle(1000)
        .drive(onNext: { [unowned self](_) in
            self.listener?.onSelectDate(date: self.picker.date)
        }).disposed(by: bag)
        self.dateContentView.addSubview(doneButton)
        
        self.doneButton.snp.makeConstraints { (btn) in
            btn.bottom.leading.trailing.equalTo(self.dateContentView).inset(12)
            btn.height.equalTo(44)
        }
        
        //date picker
        self.picker = MonthYearPickerView.init(frame:
            CGRect.init(x: 0, y: 0, width: self.dateContentView.frame.size.width, height: self.dateContentView.frame.size.height - 66))
                self.dateContentView.addSubview(self.picker)
                self.picker.snp.makeConstraints { (picker) in
                    picker.top.leading.trailing.equalTo(self.dateContentView).inset(16)
                    picker.bottom.equalTo(self.doneButton.snp.top).inset(8)
                }
        self.picker.setDate(self.dateSelected, animated: false)
    }
    
    func addShadow(view: UIView) {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 6
    }
    
    @IBAction func clickBackground(_ sender: Any) {
        self.listener?.onSelectDate(date: nil)
    }
}
