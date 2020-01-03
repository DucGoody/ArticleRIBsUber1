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
    private var todoView: UIView = UIView()
    private var dateSelected: Date = Date()
    weak var listener: DatePickerPresentableListener?
    
    init(dateSelected: Date, viewInput: UIView) {
        super.init(nibName: "DatePickerViewController", bundle: nil)
        self.dateSelected = dateSelected
        self.todoView = viewInput
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
        let originY = todoView.frame.origin.y + todoView.frame.size.height
        dateContentView = UIView()
        dateContentView.backgroundColor = .white
        dateContentView.layer.cornerRadius = 5
        backgroundView.addSubview(dateContentView)
        dateContentView.snp.makeConstraints { (dateView) in
            dateView.height.equalTo(200)
            dateView.left.right.equalTo(view).inset(16)
            dateView.top.equalTo(view).inset(originY)
        }
        addShadow(view: dateContentView)
        
        //button done
        doneButton = UIButton()
        doneButton.setTitle("Xong", for: .normal)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 5
        doneButton.backgroundColor = UIColor.link
        doneButton.rx.tap.asDriver()
        .throttle(1000)
        .drive(onNext: { [unowned self](_) in
            self.listener?.onSelectDate(date: self.picker.date)
        }).disposed(by: bag)
        dateContentView.addSubview(doneButton)
        
        doneButton.snp.makeConstraints { (btn) in
            btn.bottom.leading.trailing.equalTo(dateContentView).inset(12)
            btn.height.equalTo(44)
        }
        
        //date picker
        let widthPicker = dateContentView.frame.size.width
        let heightPicker = dateContentView.frame.size.height - 66
        let todoPicker = CGRect.init(x: 0, y: 0, width: widthPicker, height: heightPicker)
        picker = MonthYearPickerView.init(frame: todoPicker)
        dateContentView.addSubview(picker)
        picker.snp.makeConstraints { (picker) in
            picker.top.leading.trailing.equalTo(dateContentView).inset(16)
            picker.bottom.equalTo(doneButton.snp.top).inset(8)
        }
        picker.setDate(dateSelected, animated: false)
    }
    
    func addShadow(view: UIView) {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 6
    }
    
    @IBAction func clickBackground(_ sender: Any) {
        listener?.onSelectDate(date: nil)
    }
}
