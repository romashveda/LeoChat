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

    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        loginButton.center = view.center
        
        view.addSubview(loginButton)
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            // go to next VC
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

