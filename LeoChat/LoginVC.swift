//
//  ViewController.swift
//  LeoChat
//
//  Created by Roman Shveda on 4/19/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class LoginVC: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    @IBAction func logIn(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        loginButton.center = view.center
        view.addSubview(loginButton)
        if let accessToken = AccessToken.current {
            print("User logged")
            performSegue(withIdentifier: "toTabBar", sender: self)
            // User is logged in, use 'accessToken' here.
            // go to next VC
        } else {
            print("User not logged")
        }
        self.navigationController?.isNavigationBarHidden = true
        loginTextField.delegate = self
        passTextField.delegate = self
        self.hideKeyboardOnTap(#selector(self.dismissKeyboard))
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LoginVC: UITextFieldDelegate {
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func hideKeyboardOnTap(_ selector: Selector) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

