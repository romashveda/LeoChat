//
//  UsersVC.swift
//  LeoChat
//
//  Created by Roman Shveda on 4/21/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit
import CoreData

protocol UserSelectionDelegate: class {
    func userSelected(_ newUser: User)
}

class UsersVC: UITableViewController {
    
    weak var delegate: UserSelectionDelegate?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem.title = "Chats"
        removeCurrentUser()
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
        cell.userLabel.text = users[indexPath.row].login

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenUser = users[indexPath.row]
        delegate?.userSelected(chosenUser!)
        if let chatVC = delegate as? ChatVC,
        let navChatVC = chatVC.navigationController {
            splitViewController?.showDetailViewController(navChatVC, sender: nil)
        }
        
    }
}

class UserCell: UITableViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    
}
