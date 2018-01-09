//
//  MainVC.swift
//  Ping
//
//  Created by Brian Lin on 7/13/17.
//  Copyright © 2017 Avinash Jain. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class reminderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reminderName: UILabel!
    @IBOutlet weak var reminderDescription: UITextView!
    @IBOutlet weak var reminderIcon: UIImageView!
    
}

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let ref = Database.database().reference()
    let eventsRef = Database.database().reference(withPath: "master-reminder")
    
    var tappedTableView = false
    var eventArray : [NSDictionary] = []
    var id_to_pass = "123";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pullData()
        tableView.register(UINib(nibName: "reminderCellTVC", bundle: nil), forCellReuseIdentifier: "reminder")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func pullData(){
        eventsRef.queryOrdered(byChild: "master-reminder")
            .observeSingleEvent(of: .value, with: { snapshot in
                
                for child in snapshot.children.allObjects as? [DataSnapshot] ?? []{
                    
                    var ownershipStatus="";
                    if (child.childSnapshot(forPath: "reminder_ownerID").value as! String == universalUserID) {
                        print("sent by this user")
                        ownershipStatus="sent"
                    }
                    else {
                        print("received from others")
                        ownershipStatus="receive"
                    }
                    
                    let eventDataSimp: [String: AnyObject] =  ["reminder_name":child.childSnapshot(forPath: "reminder_name").value as! String as AnyObject,
                                                            "reminder_details":child.childSnapshot(forPath: "reminder_details").value as! String as AnyObject,
                                                            "reminder_ownerID":child.childSnapshot(forPath: "reminder_ownerID").value as! String as AnyObject,
                                                            "reminder_id":child.key as AnyObject,
                                                            "ownership_status":ownershipStatus as AnyObject,
                                                            "reminder_hour":child.childSnapshot(forPath: "reminder_time").childSnapshot(forPath: "reminder_hour").value as! String as AnyObject,
                                                            "reminder_minute":child.childSnapshot(forPath: "reminder_time").childSnapshot(forPath: "reminder_minute").value as! String as AnyObject,
                                                            "reminder_recipient":child.childSnapshot(forPath: "reminder_recipient").value as! NSArray,
                                                            ]
                    
                    self.eventArray.append(eventDataSimp as NSDictionary)
                    self.tableView.reloadData()
                }
                print("DONE")
            })
        
    }
    
    func sendData()
    {
        let newReminderRef = self.ref
            .child("master-reminder")
            .childByAutoId()
        
        let newRemindertId = newReminderRef.key
        let newRemindertData:[String: AnyObject]  = [
            "reminder_id": newRemindertId as AnyObject,
            "reminder_name":"Reminder 2" as AnyObject,
            "reminder_details":"details 2" as AnyObject,
            "reminder_ownerID": "OWNER ID"as AnyObject ,
            "reminder_time": ["reminder_month":"MONTH", "reminder_day":"DAY", "reminder_hour":"HOUR", "reminder_minute":"MINUTE", "reminder_second":"SECOND", "reminder_zone":"GMT"] as AnyObject,
            "reminder_recipient": ["PLAYER_ID", "PLAYER_ID"] as AnyObject
        ]
        
        newReminderRef.setValue(newRemindertData)
        print("data sent")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return self.eventArray.count
    }
    
    @IBAction func logoClck(_ sender: Any) {
//        let alertViewResponder: SCLAlertViewResponder = SCLAlertView().showSuccess("Hello World", subTitle: "This is a more descriptive text.")
//        alertViewResponder.setTitle("New Title") // Rename title
//        alertViewResponder.setSubTitle("New description") // Rename subtitle
//        alertViewResponder.close() // Close view
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Log Out") {
            print("first button tapped")
            try! Auth.auth().signOut()
            self.performSegue(withIdentifier: "logOut", sender: nil)

        }
        alertView.addButton("Dismiss") {
            print("Second button tapped")
        }
        alertView.showSuccess("Button View", subTitle: "This alert view has buttons")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminder", for: indexPath) as! reminderTableViewCell
        cell.selectionStyle = .none
        let currentEvent = eventArray[indexPath.row]
       
        let hour = currentEvent.value(forKey: "reminder_hour")
        let minute = currentEvent.value(forKey: "reminder_minute")
        
        var imgString=""
        if (currentEvent.value(forKey: "ownership_status") as! String == "sent") {
            imgString="Sent"
            
            let recipientArray = currentEvent.value(forKey: "reminder_recipient") as! NSArray
            var nameString = ""
            
                for indiv in recipientArray {
                    self.GetUserName(uid: indiv as! String) { (name) -> () in
                        nameString = nameString + name + ", "
                        cell.reminderDescription.text="Sent to \(nameString)reminder at \(hour as! String):\(minute as! String)."
                    }
                }
        }
        else if (currentEvent.value(forKey: "ownership_status") as! String=="receive"){
            imgString="Rec"
            self.GetUserName(uid: currentEvent.value(forKey: "reminder_ownerID") as! String) { (name) -> () in
            cell.reminderDescription.text="Sent by \(name), reminder at \(hour as! String):\(minute as! String)."
            }
        }
        
        cell.reminderName.text = currentEvent.value(forKey: "reminder_name") as? String
        
        cell.reminderIcon.image = UIImage(named: "\(imgString)_Icon.png")
        cell.backgroundColor = UIColor.clear
        self.tableView.rowHeight = 90.0
        
        return cell
    }
    
    func GetUserName(uid:String , completion: @escaping (String) -> ()) {
        ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot:DataSnapshot) in
            
            if (snapshot.value != nil) {
                let val = snapshot.value as! [String: Any]
                if let username = val["user_firstName"]! as? String {
                    completion(username)
            }
        }
        else {
            completion("")
        }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
