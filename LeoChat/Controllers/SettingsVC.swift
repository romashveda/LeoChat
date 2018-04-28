//
//  SettingsVC.swift
//  LeoChat
//
//  Created by Roman Shveda on 4/25/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit
import FacebookLogin

class SettingsVC: UIViewController {
    
    var currentUser: User?
    var loggedWithFacebook: Bool?
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var aboutBlock: UILabel!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var heightOfAbout: NSLayoutConstraint!
    @IBOutlet weak var verticalSpacing: NSLayoutConstraint!
    
    var clicked = false
    let logOutButton = LoginButton(readPermissions: [.email, .publicProfile])
    
    @IBAction func showAboutBlock(_ sender: UIButton) {
        clicked = !clicked
        if clicked {
            verticalSpacing.constant = 0
        }else {
            verticalSpacing.constant = 301
        }
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func logOutAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toMain", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailLabel.text = currentUser?.email
        loginLabel.text = currentUser?.login
        logOut.layer.cornerRadius = 15
        if loggedWithFacebook! {
            logOut.isHidden = true
            view.addSubview(logOutButton)
        }
    }

}
