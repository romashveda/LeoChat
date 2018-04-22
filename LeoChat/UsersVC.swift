//
//  UsersVC.swift
//  LeoChat
//
//  Created by Roman Shveda on 4/21/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit
import CoreData

class UsersVC: UITableViewController {
    
    var users: [User] = []
    var messages: [Message] = []

    @IBOutlet weak var usersTableView: UITableView!
    
    func setupData() {
        clearData()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        let vitalii = User(context: context)
        vitalii.login = "vitalii"
        vitalii.email = "\(vitalii.login!)@gmail.com"
        vitalii.pass = "1111"
        let gordon = User(context: context)
        gordon.login = "gordon"
        gordon.email = "\(gordon.login!)@gmail.com"
        gordon.pass = "1111"
        let lui = User(context: context)
        lui.login = "lui"
        lui.email = "\(lui.login!)@gmail.com"
        lui.pass = "1111"
        do {
            try context.save()
        } catch {
            print("error")
        }
        loadData()
        
    }
    
    func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        
        do {
            users = try context.fetch(fetchRequest) as! [User]
        } catch {
            
        }
    }
    
    func clearData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            let users = try(context.fetch(fetchRequest) as? [User])
            for user in users! {
                context.delete(user)
            }
            try context.save()
        } catch let err{
            print(err)
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        setupData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChatVC" {
            let nav = segue.destination as! ChatVC

        }
    }

}

extension UsersVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = usersTableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        usersTableView.rowHeight = 100
        let u = users as! [User]
        cell.userLabel.text = u[indexPath.row].login

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
