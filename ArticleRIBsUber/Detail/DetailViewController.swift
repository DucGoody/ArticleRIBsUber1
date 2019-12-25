//
//  DetailViewController.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/23/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import RIBs
import RxSwift
import UIKit
import WebKit
import SnapKit

protocol DetailPresentableListener: class {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class DetailViewController: UIViewController, DetailPresentable, DetailViewControllable {
    private var webView: WKWebView!
    weak var listener: DetailPresentableListener?
    private var url: URL!
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Method is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        self.view.addSubview(webView)
        
        webView.snp.makeConstraints { (web) in
            web.top.leading.trailing.bottom.equalTo(self.view)
        }
        let request = URLRequest.init(url: url)
        webView.load(request)
    }
}
