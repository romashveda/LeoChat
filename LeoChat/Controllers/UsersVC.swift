//
//  UsersVC.swift
//  LeoChat
//
//  Created by Roman Shveda on 4/21/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit
import CoreData

class UsersVC: UIViewController {
    
    var users: [User] = []
    var messages: [Message] = []
    var currentUser: User!
    var chosenUser: User?

    @IBOutlet weak var usersTableView: UITableView!
    
    func removeCurrentUser() {
        for i in 0..<users.count {
            if users[i].login == currentUser.login {
                users.remove(at: i)
                break
            }
        }
    }
    
    static func createMessageWithText(text: String, user: User, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false) -> Message{
        let message = Message(context: context)
        message.userTo = user
        message.text = text
        message.date = Date().addingTimeInterval(-minutesAgo*60)
        message.isSender = isSender
        return message
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        tabBarItem.title = "Chats"
        removeCurrentUser()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChatVC" {
            let nav = segue.destination as! ChatVC
            nav.user = chosenUser
        }
    }

}

extension UsersVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = usersTableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        usersTableView.rowHeight = 100
        cell.userLabel.text = users[indexPath.row].login

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenUser = users[indexPath.row]
        performSegue(withIdentifier: "toChatVC", sender: self)
    }
}
