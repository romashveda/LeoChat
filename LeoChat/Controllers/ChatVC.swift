//
//  ChatVC.swift
//  LeoChat
//
//  Created by Roman Shveda on 4/21/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit
import CoreData

class ChatVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    
    var context = Functionallity.getContext()

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageInputView: UIView!
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var messageBottomAnchor: NSLayoutConstraint!
    
    @IBAction func saveMessage(_ sender: UIButton) {
        guard let text = messageText.text else {return}
        if text.isEmpty {
            return
        }
        _ = UsersVC.createMessageWithText(text: text, user: user!, minutesAgo: 0, context: context, isSender: true)
        do {
            try context.save()
            messageText.text = nil
        } catch {
            print(error)
        }
    }
    
    var user: User? {
        didSet{
            navigationItem.title = user?.login
        }
    }
    
//    func refreshFetchController() -> NSFetchedResultsController<NSManagedObject>{
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Message")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//        print(user?.login)
//        fetchRequest.predicate = NSPredicate(format: "userTo.login = %@", user!.login!)
//        let context = Functionallity.getContext()
//        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        frc.delegate = self
//        return frc
//    }
    
    var fetchResultController: NSFetchedResultsController<NSManagedObject>!
    
//    lazy var fetchResultController: NSFetchedResultsController<NSManagedObject> = {
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Message")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//        print(user?.login)
//        fetchRequest.predicate = NSPredicate(format: "userTo.login = %@", user!.login!)
//        let context = Functionallity.getContext()
//        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        frc.delegate = self
//        return frc
//    }()
    
    var blockOperations = [BlockOperation]()
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            blockOperations.append(BlockOperation(block: {
                self.chatTableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.automatic)
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        chatTableView.performBatchUpdates({
            for operation in blockOperations {
                operation.start()
            }
        }) { completed in
            let lastItem = self.fetchResultController.sections![0].numberOfObjects - 1
            let indexPath = IndexPath(item: lastItem, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        fetchResultController.delegate = self
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
            messageBottomAnchor.constant = -keyboardRect.height + 50
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { completed in
                let lastItem = self.fetchResultController.sections![0].numberOfObjects - 1
                let indexPath = IndexPath(item: lastItem, section: 0)
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else {
            messageBottomAnchor.constant = 50
        }
    }
    
    @objc func simulate() {
        let message = UsersVC.createMessageWithText(text: "Message simulation.", user: user!, minutesAgo: 0, context: context)
        do {
            try context.save()
            Functionallity.setNotification(with: message)
            messageText.text = nil
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchResultController.performFetch()
            print(fetchResultController.sections?[0].numberOfObjects)
        } catch {
            print(error)
        }
        self.tabBarController?.tabBar.isHidden = true
        messageText.placeholder = "Enter message..."
        chatTableView.estimatedRowHeight = 60
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }


}

extension ChatVC: UserSelectionDelegate {
    func userSelected(_ newUser: User) {
        user = newUser
    }
    func fetchControllerDelegated(_ controller: NSFetchedResultsController<NSManagedObject>) {
        fetchResultController = controller
    }
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[0].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = chatTableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }
        let message = fetchResultController.object(at: indexPath) as! Message
        cell.messageView.layer.cornerRadius = 15
        cell.messageView.layer.masksToBounds = true
        cell.messageView.backgroundColor = UIColor(red: 0.216, green: 0.217, blue: 0.233, alpha: 0.25)
        let font = UIFont(name: "Arial", size: 18)
        cell.messageText.font = font
//        guard let message = messages?[indexPath.row] else {return UITableViewCell()}
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
