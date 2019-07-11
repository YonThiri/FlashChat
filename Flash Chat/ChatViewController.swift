//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import UserNotifications


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    
    var messageArray : [Message] = [Message]()
    
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        
        
        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        sendButton.isEnabled = false
        messageTableView.separatorStyle = .none
        messageTableView.reloadData()

        
    }
    
    
    @IBAction func textChanged(_ sender: Any) {
        
        checkCount(textfield: sender as! UITextField)
    }
    
    func checkCount(textfield : UITextField){
        
        if textfield.text != ""{
            sendButton.isEnabled = true
        }
        else{
            sendButton.isEnabled = false
        }
    }
    
    
    func scrollToBottomOfChat(){
        
        let indexPath = IndexPath(row: messageArray.count - 1, section: 0)
        messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messageTextfield.endEditing(true)
        return true
    }
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String? {
            cell.avatarImageView.backgroundColor = UIColor.flatBlue()
            cell.messageBackground.backgroundColor = UIColor.flatBlue()
            cell.senderUsername.textColor = UIColor.flatWhite()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatWatermelon()
            cell.senderUsername.textColor = UIColor.flatBlack()
        }
        return cell
        
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    
    
    
    //TODO: Declare textFieldDidBeginEditing here:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.25) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
            
        }

        if messageArray.count == 0 {
            print("error")
        }
        else {
            scrollToBottomOfChat()
        }

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.25) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
            
        }
    }
    
    //TODO: Declare textFieldDidEndEditing here:
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase

    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        //TODO: Send the message to Firebase and save it in our database
        
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender" : Auth.auth().currentUser?.email,"MessageBody" : messageTextfield.text!]
        
        let message = messageTextfield.text!
        
        messagesDB.childByAutoId().setValue(messageDictionary){
            (error , reference) in
            
            if error != nil {
                print(error!)
            }else{
                print("Message saved successfully!")
                
                self.messageTextfield.isEnabled = true
                // self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
                
                //Step 1 : Ask for permission
                let noti = UNUserNotificationCenter.current()
                
                noti.requestAuthorization(options: [.alert,.sound], completionHandler: { (granted, error) in
                    
                })
                
                //Step 2 : Create the notification content
                let content = UNMutableNotificationContent()
                content.title = "New Message"
                content.body = message
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages(){
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe( .childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message()
            
            message.messageBody = text
            message.sender = sender
            
            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
            self.scrollToBottomOfChat()
            
            
        }
    }
    
    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            
        } catch{
            print("error:there was a problem with logging out..!!")
        }
        guard (navigationController?.popToRootViewController(animated: true)) != nil
            else {
                print("No view controllers to pop off")
                return
        }
        
        
    }
    
    
    
}
