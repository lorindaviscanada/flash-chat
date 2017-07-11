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

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    let MESSAGES_DB = "Messages"
    
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
        retrievMessages()
        
        messageTableView.separatorStyle = .none
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods

    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if messageArray[indexPath.row].sender == FIRAuth.auth()?.currentUser?.email {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            cell.senderUsername.backgroundColor = UIColor.white
        }
        else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
            cell.senderUsername.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    //TODO: Declare configureTableView here:
    func configureTableView () {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    
    }
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.5) { 
            self.heightConstraint.constant = 315
            self.view.layoutIfNeeded()
        }

    }
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }

    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        //TODO: Send the message to Firebase and save it in our database
        
        messageTextfield.endEditing(true)
        
        enableSendMessage(enabled: false)
        
        let messageDB = FIRDatabase.database().reference().child(MESSAGES_DB)
        
        let messageDict = ["Sender": FIRAuth.auth()?.currentUser?.email, "MessageBody" : messageTextfield.text!]

        messageDB.childByAutoId().setValue(messageDict) {
            (error, ref) in
            if error != nil {
                print(error!)
            }
            else {
                print ("Message Saved Successfully")
                self.messageTextfield.text = ""
            }
        }
        
        enableSendMessage(enabled: true)
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrievMessages() {
        
        let messageDB = FIRDatabase.database().reference().child(MESSAGES_DB)
        
        
        messageDB.observe(.childAdded, with: { (snapshot) in
        
            let snapshotValue = snapshot.value as! Dictionary<String , String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let msg = Message(messageBody: text, sender: sender)
            
            self.messageArray.append(msg)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        })
    }

    
    func enableSendMessage(enabled: Bool) {
        messageTextfield.isEnabled = enabled
        sendButton.isEnabled = enabled
        
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try FIRAuth.auth()?.signOut()
        }
        catch {
            print ("Error: there was a problem signing out")
        }
        
        guard (navigationController?.popToRootViewController(animated: true)) != nil
            else {
                print ("No view Controllers to pop off")
                return
        }
        
    }
    


}
