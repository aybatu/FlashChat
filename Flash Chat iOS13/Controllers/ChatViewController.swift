//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
   
    let db = Firestore.firestore()
 
    var messages = [Message(sender: nil, body: nil)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.title = "⚡️FlashChat"
        messageTextfield.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
 
        loadData()
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if messageTextfield.text != "" {
            sendMessage()
        }
    }
    
    func sendMessage() {
        if let message = messageTextfield.text, let sender = Auth.auth().currentUser?.email {
            db.collection("message").addDocument(data: ["messageBody" : message, "sender": sender, "date": Date().timeIntervalSince1970]) { error in
                if let e = error {
                    print("Error occured in saving data, \(e).")
                } else {
                    self.messageTextfield.text = ""
                    print("Your data has been saved succesfully.")
                }
            }
        }
    }
    
    func loadData() {
        db.collection("message").order(by: "date").addSnapshotListener() { (querySnapshot, err) in
            self.messages = []
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let querySnap = querySnapshot {
                    for doc in querySnap.documents {
                        let data = doc.data()
                        if let newMessageBody = data["messageBody"] as? String, let newMessageSender = data["sender"] as? String {
                            let newMessage = Message(sender: newMessageSender, body: newMessageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
}
//MARK: - Table View DataSource

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MessageCell
        
        if Auth.auth().currentUser?.email == messages[indexPath.row].sender {
            cell.messageView.backgroundColor = UIColor(named: "BrandPurple")
            cell.messageLabel.textColor = UIColor(named: "BrandLightPurple")
            cell.youImage.isHidden = true
            cell.senderImage.isHidden = false
        } else {
            cell.messageView.backgroundColor = UIColor(named: "BrandBlue")
            cell.messageLabel.textColor = UIColor(named: "BrandLightBlue")
            cell.senderImage.isHidden = true
            cell.youImage.isHidden = false
        }
        
        cell.messageLabel.text = self.messages[indexPath.row].body
        
        return cell
    }
}

//MARK: - Textfield Delegate

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if messageTextfield.text != ""{
            sendMessage()
            return true
        } else {
            return false
        }
    }
}
