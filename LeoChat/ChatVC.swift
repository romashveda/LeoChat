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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(displayP3Red: 199, green: 211, blue: 211, alpha: 1)
        return view
    }()
    
    var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter message..."
        field.translatesAutoresizingMaskIntoConstraints = false
        field.backgroundColor = .white
        return field
    }()
    
    var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSend() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        guard let text = textField.text else {return}
        if text.isEmpty {
            return
        }
        let message = UsersVC.createMessageWithText(text: text, user: user!, minutesAgo: 0, context: context, isSender: true)
        do {
            try context.save()
            messages?.append(message)
            let item = messages!.count - 1
            let insertionIndexPath = IndexPath(item: item, section: 0)
            chatTableView.insertRows(at: [insertionIndexPath], with: UITableViewRowAnimation.automatic)
            chatTableView.scrollToRow(at: insertionIndexPath, at: .bottom, animated: true)
            textField.text = nil
        } catch {
            print(error)
        }
    }
    
    var borderLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        self.hideKeyboardOnTap(#selector(self.dismissKeyboard))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .done, target: self, action: #selector(simulate))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        if notification.name == Notification.Name.UIKeyboardWillShow ||
            notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            chatTableView.frame.origin.y = -keyboardRect.height
        } else {
            chatTableView.frame.origin.y = 0
        }
    }
    
    @objc func simulate() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        let message = UsersVC.createMessageWithText(text: "Message simulation.", user: user!, minutesAgo: 0, context: context)
        do {
            try context.save()
            messages?.append(message)
            Functionallity.setNotification(with: message)
            let item = messages!.count - 1
            let insertionIndexPath = IndexPath(item: item, section: 0)
            chatTableView.insertRows(at: [insertionIndexPath], with: UITableViewRowAnimation.automatic)
            chatTableView.scrollToRow(at: insertionIndexPath, at: .bottom, animated: true)
            textField.text = nil
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let screen = UIScreen.main.bounds
        
        view.addSubview(messageInputContainer)
        messageInputContainer.addSubview(textField)
        messageInputContainer.addSubview(sendButton)
        messageInputContainer.addSubview(borderLine)
        
        messageInputContainer.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0).isActive = true
        messageInputContainer.widthAnchor.constraint(equalToConstant: screen.width).isActive = true
        messageInputContainer.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        textField.bottomAnchor.constraint(equalTo: messageInputContainer.layoutMarginsGuide.bottomAnchor, constant: 0).isActive = true
        textField.widthAnchor.constraint(equalToConstant: screen.width - 80).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.leadingAnchor.constraint(equalTo: messageInputContainer.layoutMarginsGuide.leadingAnchor, constant: 5).isActive = true
        
        sendButton.trailingAnchor.constraint(equalTo: messageInputContainer.layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: messageInputContainer.layoutMarginsGuide.centerYAnchor).isActive = true
        
        borderLine.topAnchor.constraint(equalTo: messageInputContainer.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
        borderLine.widthAnchor.constraint(equalToConstant: screen.width).isActive = true
        borderLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        

        
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
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
        
        if message.isSender {
            cell.messageView.backgroundColor = .blue
            cell.messageText.textColor = .white
            cell.messageText.textAlignment = .right
            let temp = cell.leadingConstraint.constant
            cell.leadingConstraint.constant = cell.trailingConstraint.constant
            cell.trailingConstraint.constant = temp
        }
        return cell
    }
    
}

extension ChatVC: UITextFieldDelegate {
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

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageText: UILabel!{
        didSet{
            messageText.layer.cornerRadius = 10
        }
    }
}
