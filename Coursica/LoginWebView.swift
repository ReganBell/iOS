//
//  LoginWebView.swift
//  Coursica
//
//  Created by Regan Bell on 7/3/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

enum LoginErrorType {
    case NetworkError, InvalidCredentials
}

protocol LoginWebViewDelegate {
    
    func didLoginSuccessfullyWithHUID(huid: String)
    func didLoadCS50CoursesSuccessfullyWithLists(lists: [CourseList])
    func didFailWithError(error: LoginErrorType)
}

class LoginWebView: UIWebView {
    
    var loginScreenLoaded: Bool = false
    var usernameTried: Bool = false
    var usernameToTry: String = ""
    var passwordToTry: String = ""
    var loginDelegate: LoginWebViewDelegate?
    
    func loadLoginScreen() {
        
        self.loadRequest(NSURLRequest(URL: NSURL(string: "https://courses.cs50.net/classes/login")!))
        self.delegate = self
    }
    
    func tryUsernameWhenReady(username: String, password: String) {
        
        if loginScreenLoaded {
            self.tryUsername(username, password: password)
        } else {
            self.usernameToTry = username
            self.passwordToTry = password
        }
    }
    
    func tryUsername(username: String, password: String) {
        
        usernameTried = true
        self.stringByEvaluatingJavaScriptFromString("setContent('PIN','Harvard University ID (HUID)');")
        self.stringByEvaluatingJavaScriptFromString("document.getElementById('username').value = '\(username)'")
        self.stringByEvaluatingJavaScriptFromString("document.getElementById('password').value = '\(password)'")
        self.stringByEvaluatingJavaScriptFromString("document.getElementsByName('_eventId_submit')[0].click()")
    }
    
    func scrapeListIDs(timer: NSTimer) {
        
        let listIDs = self.stringByEvaluatingJavaScriptFromString("var lists = document.getElementsByClassName('list-link'); var ids = new Array(lists.length); for (i = 0; i < ids.length; i++) { ids[i] = lists[i].getAttribute('data-list-id') }; ids.toString()")!.componentsSeparatedByString(",")
        let listCounts = self.stringByEvaluatingJavaScriptFromString("var lists = document.getElementsByClassName('list-link'); var ids = new Array(lists.length); for (i = 0; i < ids.length; i++) { ids[i] = lists[i].getAttribute('data-list-count') }; ids.toString()")!.componentsSeparatedByString(",")
        let namesString = self.stringByEvaluatingJavaScriptFromString("var lists = document.getElementsByClassName('list-link'); var names = new Array(lists.length); for (i = 1; i < names.length; i++) { names[i] = lists[i].getElementsByClassName('list-name')[0].innerText} names.toString()")
        let listNames = ("Starred Courses" + namesString!).componentsSeparatedByString(",")
        
        var activeLists: [CourseList] = []
        for (index, listId) in enumerate(listIDs) {
            if let intValue = listCounts[index].toInt() {
                if intValue > 0 {
                    let newList = CourseList(name: listNames[index], courses: [])
                    newList.id = listId
                    activeLists.append(newList)
                }
            }
        }
        if listIDs.count < 2 {
            return
        } else {
            self.loginDelegate?.didLoadCS50CoursesSuccessfullyWithLists(activeLists)
            timer.invalidate()
        }
    }
}

extension LoginWebView: UIWebViewDelegate {
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if !usernameToTry.isEmpty && !usernameTried {
            self.tryUsername(usernameToTry, password: passwordToTry)
        }
        if loginScreenLoaded {
            if self.request?.URL?.absoluteString == "https://courses.cs50.net/" {
                NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "scrapeListIDs:", userInfo: nil, repeats: true)
            } else {
                self.loginDelegate?.didFailWithError(LoginErrorType.InvalidCredentials)
            }
        }
        loginScreenLoaded = true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        self.loginDelegate?.didFailWithError(LoginErrorType.NetworkError)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let urlString = self.request?.URL?.absoluteString {
            if urlString.hasPrefix("https://courses.cs50.net/") {
                self.loginDelegate?.didLoginSuccessfullyWithHUID(usernameToTry)
            }
        }
        return true
    }
}