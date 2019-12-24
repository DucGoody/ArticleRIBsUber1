//
//  AppComponent.swift
//  ArticleRIBsUber
//
//  Created by HoangVanDuc on 12/23/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//
import RIBs

class AppComponent: Component<EmptyDependency>, RootDependency {

    init() {
        super.init(dependency: EmptyComponent())
    }
}
