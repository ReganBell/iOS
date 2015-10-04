//
//  MapViewController.swift
//  Coursica
//
//  Created by Regan Bell on 8/18/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography

class MapViewController: CoursicaViewController {

    let urlString: String
    let webView = UIWebView()
    
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        if let URL = NSURL(string: urlString) {
            webView.loadRequest(NSURLRequest(URL: URL))
        }
        constrain(webView, block: {webView in
            webView.edges == webView.superview!.edges
        })
    }
}