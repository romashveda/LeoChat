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
import CoreData

class LoginVC: UIViewController {
    
    var fetchedUsers = [User]()
    var loginedUser: User?
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    @IBAction func logIn(_ sender: UIButton) {
        userAuthentification()
    }
    
    func userAuthentification() {
        guard let email = loginTextField.text else {return}
        guard let pass = passTextField.text else {return}
        for user in fetchedUsers {
            if email == user.email && pass == user.pass{
                loginedUser = user
                performSegue(withIdentifier: "toTabBar", sender: self)
            }
        }
        if loginedUser == nil {
            showAlert()
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Wrong credentials", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(alertAction)
        loginTextField.text = nil
        passTextField.text = nil
        present(alert,animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loginTextField.placeholder = "Email"
        loginTextField.textAlignment = .center
        passTextField.placeholder = "Password"
        passTextField.textAlignment = .center
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        loginButton.center = view.center
        view.addSubview(loginButton)
        if let accessToken = AccessToken.current {
            print("User logged")
            print(accessToken.userId!)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTabBar" {
            let nav = segue.destination as! UINavigationController
            let tab = nav.topViewController as! UITabBarController
            let userVC = tab.viewControllers![0] as! UsersVC
            userVC.users = fetchedUsers
            userVC.currentUser = loginedUser
        }
    }

    func setupData() {
        clearData()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        let vasyl = User(context: context)
        vasyl.login = "Vasyl Borovets"
        vasyl.email = "1@gmail.com"
        vasyl.pass = "1111"
        let ihor = User(context: context)
        ihor.login = "Ihor Avramenko"
        ihor.email = "ihor"
        ihor.pass = "1111"
        let denys = User(context: context)
        denys.login = "Denys Melnyk"
        denys.email = "3@gmail.com"
        denys.pass = "1111"
        
        _ = UsersVC.createMessageWithText(text: "Hey, how are you? Will attempt to recover by breaking constraint.", user: vasyl, minutesAgo: 5,context: context)
        _ = UsersVC.createMessageWithText(text: "What's up? Make a symbolic breakpoint at UIViewAlertForUnsatisfiableConstraints to catch this in the debugger.", user: ihor, minutesAgo: 1,context: context)
        _ = UsersVC.createMessageWithText(text: "Hi!", user: vasyl, minutesAgo: 4,context: context)
        _ = UsersVC.createMessageWithText(text: "Brilliant", user: vasyl, minutesAgo: 2,context: context)
        _ = UsersVC.createMessageWithText(text: "I'm fine.", user: vasyl, minutesAgo: 1, context: context, isSender: true)
        
        do {
            try context.save()
        } catch {
            print("error")
        }
        fetchUsers()
        
    }
    
    func fetchUsers() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            let users = try context.fetch(request) as! [User]
            fetchedUsers.append(contentsOf: users)
        } catch {
            print(error)
        }
    }
    
    func clearData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let entities = ["Message","User"]
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
            do {
                let objects = try context.fetch(fetchRequest)
                for object in objects {
                    context.delete(object)
                }
                try context.save()
            } catch {
                print(error)
            }
        }
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

