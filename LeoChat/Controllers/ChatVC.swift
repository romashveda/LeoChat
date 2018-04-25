//
//  ChatVC.swift
//  LeoChat
//
//  Created by Roman Shveda on 4/21/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageInputView: UIView!
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var messageBottomAnchor: NSLayoutConstraint!
    
    @IBAction func saveMessage(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        guard let text = messageText.text else {return}
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
            messageText.text = nil
        } catch {
            print(error)
        }
    }
    var messages: [Message]?
    var user: User? {
        didSet{
            navigationItem.title = user?.login
            messages = user?.messages?.allObjects as? [Message]
            messages = messages?.sorted{$0.date! < $1.date!}
        }
    }
//    var messageInputContainer: UIView = {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = UIColor(displayP3Red: 199, green: 211, blue: 211, alpha: 1)
//        return view
//    }()
//
//    var textField: UITextField = {
//        let field = UITextField()
//        field.placeholder = "Enter message..."
//        field.translatesAutoresizingMaskIntoConstraints = false
//        field.backgroundColor = .white
//        return field
//    }()
//
//    var sendButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Send", for: .normal)
//        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
//        return button
//    }()
    
//    @objc func handleSend() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//        let context = appDelegate.persistentContainer.viewContext
//        guard let text = textField.text else {return}
//        if text.isEmpty {
//            return
//        }
//        let message = UsersVC.createMessageWithText(text: text, user: user!, minutesAgo: 0, context: context, isSender: true)
//        do {
//            try context.save()
//            messages?.append(message)
//            let item = messages!.count - 1
//            let insertionIndexPath = IndexPath(item: item, section: 0)
//            chatTableView.insertRows(at: [insertionIndexPath], with: UITableViewRowAnimation.automatic)
//            chatTableView.scrollToRow(at: insertionIndexPath, at: .bottom, animated: true)
//            textField.text = nil
//        } catch {
//            print(error)
//        }
//    }
    
//    var borderLine: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(white: 0.5, alpha: 1)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        textField.delegate = self
        chatTableView.delegate = self
        chatTableView.dataSource = self
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
            messageBottomAnchor.constant = -keyboardRect.height
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { completed in
                if self.messages?.count != 0 {
                let indexPath = IndexPath(item: self.messages!.count - 1, section: 0)
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        } else {
            messageBottomAnchor.constant = 0
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
            messageText.text = nil
        } catch {
            print(error)
        }
    }
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        viewWillAppear(true)
//        if UIDevice.current.orientation.isLandscape{
//            screen = UIScreen.main.bounds
//            viewWillAppear(true)
//        }else {
//            screen = UIScreen.main.bounds
//            viewWillAppear(true)
//        }
//    }
//    var bottomConstraint: NSLayoutConstraint?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        var screen = UIScreen.main.bounds
        messageText.placeholder = "Enter message..."
        chatTableView.estimatedRowHeight = 60
        chatTableView.rowHeight = UITableViewAutomaticDimension
//        view.addSubview(messageInputContainer)
//        messageInputContainer.addSubview(textField)
//        messageInputContainer.addSubview(sendButton)
//        messageInputContainer.addSubview(borderLine)
        
//        bottomConstraint = messageInputContainer.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0)
//        bottomConstraint?.isActive = true
//        messageInputContainer.widthAnchor.constraint(equalToConstant: screen.width).isActive = true
//        messageInputContainer.heightAnchor.constraint(equalToConstant: 70).isActive = true
//
//        textField.bottomAnchor.constraint(equalTo: messageInputContainer.layoutMarginsGuide.bottomAnchor, constant: 0).isActive = true
//        textField.widthAnchor.constraint(equalToConstant: screen.width - 80).isActive = true
//        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        textField.leadingAnchor.constraint(equalTo: messageInputContainer.layoutMarginsGuide.leadingAnchor, constant: 5).isActive = true
//
//        sendButton.trailingAnchor.constraint(equalTo: messageInputContainer.layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true
//        sendButton.centerYAnchor.constraint(equalTo: messageInputContainer.layoutMarginsGuide.centerYAnchor).isActive = true
//
//        borderLine.topAnchor.constraint(equalTo: messageInputContainer.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
//        borderLine.widthAnchor.constraint(equalToConstant: screen.width).isActive = true
//        borderLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        

        
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }


}

extension ChatVC: UITableViewDelegate, UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = messages?.count ?? 0
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = chatTableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }
        cell.messageView.layer.cornerRadius = 15
        cell.messageView.backgroundColor = UIColor(red: 0.216, green: 0.217, blue: 0.233, alpha: 0.25)
        let font = UIFont(name: "Arial", size: 18)
        cell.messageText.font = font
        guard let message = messages?[indexPath.row] else {return UITableViewCell()}
        cell.messageText.text = message.text
        cell.messageView.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor, constant: 0)
        cell.isUserInteractionEnabled = false
        if message.isSender {
            cell.messageView.backgroundColor = .green
            cell.messageText.textColor = .white
            cell.messageText.textAlignment = .right
            let temp = cell.leadingConstraint.constant
            cell.leadingConstraint.constant = cell.trailingConstraint.constant
            cell.trailingConstraint.constant = temp
        }
        return cell
    }
    
}

extension ChatVC {
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
