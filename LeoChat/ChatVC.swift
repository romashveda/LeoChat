//
//  ChatVC.swift
//  LeoChat
//
//  Created by Roman Shveda on 4/21/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit

class ChatVC: UITableViewController {

    @IBOutlet weak var chatTableView: UITableView!
    var messages: [Message]?
    var user: User? {
        didSet{
            navigationItem.title = user?.login
            messages = user?.messages?.allObjects as? [Message]
            messages = messages?.sorted{$0.date! < $1.date!}
        }
    }
    var messageInputContainer: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(messageInputContainer)
//        messageInputContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
//        messageInputContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        messageInputContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        messageInputContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        messageInputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageInputContainer.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0).isActive = true
        messageInputContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        messageInputContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }




}

extension ChatVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = messages?.count ?? 0
        return num
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = chatTableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }
        cell.messageView.layer.cornerRadius = 15
        cell.messageView.backgroundColor = UIColor.lightGray
        let font = UIFont(name: "Arial", size: 18)
        cell.messageText.font = font
        guard let message = messages?[indexPath.row] else {return UITableViewCell()}
        cell.messageText.text = message.text
        cell.messageView.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor, constant: 0)
        NSLayoutConstraint(item: cell.messageView, attribute: .leading, relatedBy: <#T##NSLayoutRelation#>, toItem: <#T##Any?#>, attribute: <#T##NSLayoutAttribute#>, multiplier: <#T##CGFloat#>, constant: <#T##CGFloat#>)
        if message.isSender {
            cell.messageView.backgroundColor = .blue
            cell.messageText.textColor = .white
            cell.messageText.textAlignment = .right
//            let temp = cell.leadingConstraint.constant
//            cell.leadingConstraint.constant = cell.trailingConstraint.constant
//            cell.trailingConstraint.constant = temp
        }
        return cell
    }
    
}

class ChatCell: UITableViewCell {
    
    //@IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    //@IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageText: UILabel!{
        didSet{
            messageText.layer.cornerRadius = 10
        }
    }
}
