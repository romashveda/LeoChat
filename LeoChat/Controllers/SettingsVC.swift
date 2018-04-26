//
//  SettingsVC.swift
//  LeoChat
//
//  Created by Roman Shveda on 4/25/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    var currentUser: User?
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var oldPassText: UITextField!
    @IBOutlet weak var newPassText: UITextField!
    @IBOutlet weak var saveUpdates: UIButton!
    @IBOutlet weak var logOut: UIButton!
    
    @IBAction func saveUpdatesAction(_ sender: UIButton) {
        
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailLabel.text = currentUser?.email
        loginLabel.text = currentUser?.login
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }



}
