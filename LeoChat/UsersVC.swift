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
    var chosenUser: User?

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
        
        createMessageWithText(text: "Hey, how are you? Will attempt to recover by breaking constraint.", user: vitalii, minutesAgo: 5,context: context)
        createMessageWithText(text: "What's up? Make a symbolic breakpoint at UIViewAlertForUnsatisfiableConstraints to catch this in the debugger.", user: gordon, minutesAgo: 1,context: context)
        createMessageWithText(text: "Hi!", user: vitalii, minutesAgo: 4,context: context)
        createMessageWithText(text: "Brilliant", user: vitalii, minutesAgo: 2,context: context)
        createMessageWithText(text: "I'm fine.", user: vitalii, minutesAgo: 1, context: context, isSender: true)
        
        do {
            try context.save()
        } catch {
            print("error")
        }
        loadData()
        
    }
    
    func createMessageWithText(text: String, user: User, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false) {
        let message = Message(context: context)
        message.userTo = user
        message.text = text
        message.date = Date().addingTimeInterval(-minutesAgo*60)
        message.isSender = isSender
    }
    
    func fetchUsers() -> [User]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            return try context.fetch(request) as? [User]
        } catch {
            print(error)
        }
        return nil
    }
    
    func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        guard let users = fetchUsers() else {return}
        for user in users {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Message")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "userTo.login = %@", user.login!)
            fetchRequest.fetchLimit = 1
            do {
                let message = try context.fetch(fetchRequest) as! [Message]
                messages.append(contentsOf: message)
            } catch {
                
            }
            
            messages = messages.sorted{$0.date! > $1.date!}
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        navigationItem.title = "Chats"
        setupData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChatVC" {
            let nav = segue.destination as! ChatVC
            nav.user = chosenUser
        }
    }

}

extension UsersVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = usersTableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        usersTableView.rowHeight = 100
//        let u = messages as! [User]
        cell.userLabel.text = messages[indexPath.row].userTo?.login
        cell.messageLabel.text = messages[indexPath.row].text

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenUser = messages[indexPath.row].userTo
        performSegue(withIdentifier: "toChatVC", sender: self)
    }
}
