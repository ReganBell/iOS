//
//  LoginViewController.swift
//  Coursica
//
//  Created by Regan Bell on 8/2/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    
    func userDidLoginWithHUID(HUID: String)
}

class LoginViewController: CoursicaViewController {

    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var errorMessageLabel: UILabel!
    
    @IBOutlet var messageHUIDSpace: NSLayoutConstraint!
    @IBOutlet var titlePasswordSpace: NSLayoutConstraint!
    @IBOutlet var keyboardHeight: NSLayoutConstraint!
    
    @IBOutlet var keyboardView: UIView!
    var delegate: LoginViewControllerDelegate!
    
    var userDidSubmit = false
    var PINSiteTried = false
    var UIStateError = false
    var allowAnyLogin = false
    var screenIsSmall: Bool { get { return UIScreen.mainScreen().bounds.size.height < 568 } }
    var titleTopSpaceInitial: CGFloat = 0
    var titleTopSpaceError: CGFloat { get { return self.titleTopSpaceInitial + (self.screenIsSmall ? 5 : 25) } }
    var secondsWaitedByUser = 0
    
    func checkAllowAnyLogin() {
        
        let urlString = "glaring-heat-9505.firebaseIO.com/allowAnyLogin"
        let root = Firebase(url: urlString)
        weak var weakSelf = self
        root.observeSingleEventOfType(FEventType.Value, withBlock: {snapshot in
            if let flag = snapshot.value as? Bool {
                weakSelf?.allowAnyLogin = flag
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAllowAnyLogin()

        usernameField.layer.cornerRadius = 4.0
        passwordField.layer.cornerRadius = 4.0
        
        usernameField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        passwordField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        
        usernameField.returnKeyType = .Next
        passwordField.returnKeyType = .Go
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        loginButton.layer.cornerRadius = 2
        loginButton.clipsToBounds = true
        
        titleTopSpaceInitial = titlePasswordSpace.constant;
        
        if (UIScreen.mainScreen().bounds.size.height < 568) {
            messageHUIDSpace.constant -= 8;
        }
        
        self.registerKeyboardNotifications()
        
        let backgroundImageView = UIImageView(image: UIImage(named: "jharvard_dark.jpg"))
        backgroundImageView.frame = self.view.bounds
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
    }
    
    func waitingTitle() -> String {
        switch secondsWaitedByUser {
        case 0, 1: return "Logging in..."
        case 2, 3, 4: return "Still working..."
        default: return "Almost there..."
        }
    }
    
    func updateWaitingMessage(timer: NSTimer) {
        
        secondsWaitedByUser++
        if let _ = errorMessageLabel.text {
            timer.invalidate()
            return
        }
        loginButton.setTitle(self.waitingTitle(), forState: .Normal)
    }
    
    func displayErrorMessage(errorMessage: String?) {
        let errorState = errorMessage != nil
        errorMessageLabel.text = errorMessage
        titlePasswordSpace.constant = errorState ? titleTopSpaceError : titleTopSpaceInitial
        loginButton.setTitle("Log in", forState: .Normal)
        UIView.animateWithDuration(0.3, animations: {
            self.errorMessageLabel.alpha = errorState ? 1 : 0
            self.view.layoutIfNeeded()
            self.loginButton.backgroundColor = errorState ? UIColor(red: 1, green: 30/255.0, blue: 31/255.0, alpha: 1) : coursicaBlue
        })
    }
    
    @IBAction func loginButtonPressed(button: UIButton?) {
        guard let username = usernameField.text where !username.isEmpty else {
            displayErrorMessage("Your HUID is required to log in.")
            return
        }
        guard let password = passwordField.text where !password.isEmpty else {
            displayErrorMessage("Your password is required to log in.")
            return
        }
        loginButton.setTitle("Logging in...", forState: .Normal)
        secondsWaitedByUser = 0
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateWaitingMessage:", userInfo: nil, repeats: true)
        weak var weakSelf: LoginViewController! = self
        Login.attemptLoginWithCredentials(username, password: password, completionBlock: {success, error in
            if success || weakSelf.allowAnyLogin {
                weakSelf.usernameField.resignFirstResponder()
                weakSelf.passwordField.resignFirstResponder()
                weakSelf.delegate.userDidLoginWithHUID(username)
                weakSelf.dismissViewControllerAnimated(true, completion: nil)
            } else {
                weakSelf.displayErrorMessage(error)
            }
        })
    }
    
    // MARK: Keyboard
    
    func registerKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChangeFrame:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChangeFrame:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func keyboardChangeFrame(notification: NSNotification) {
        
        let endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let curve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue
        let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        keyboardHeight.constant = endFrame.height
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration as CFTimeInterval)
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.view.layoutIfNeeded()
        UIView.commitAnimations()
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == .Next {
            passwordField.becomeFirstResponder()
        } else {
            self.loginButtonPressed(nil)
        }
        return true
    }
}

