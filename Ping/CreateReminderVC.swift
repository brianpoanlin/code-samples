
//
//  CreateReminderVC.swift
//  Ping
//
//  Created by Brian Lin on 7/13/17.
//  Copyright © 2017 Avinash Jain. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SCLAlertView

class CreateReminderVC: UIViewController {
    
    @IBOutlet weak var reminderNameTF: UITextField!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    @IBOutlet weak var recipientsButton: UIButton!
    
    var singleRecipient=""
    
    let ref = Database.database().reference()
    let eventsRef = Database.database().reference(withPath: "master-reminder")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipientsButton.titleLabel?.textAlignment = .left
        reminderDatePicker.locale = Locale(identifier: "en-US")

//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.
    }
    @IBAction func tappedRecip(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Avi") {
            print("Avi Selected")
            self.singleRecipient = "e8GRXmBTPTg6pkUmSo8sOp70VeP2"
            self.recipientsButton.titleLabel?.text = "Avi"
        }
        alertView.addButton("Brian") {
            print("Brian Selected")
            self.singleRecipient = "XpDRNskn2pNuiDgn4QvcVvdDaB22"
            self.recipientsButton.titleLabel?.text = "Brian"

        }
        alertView.showSuccess("Button View", subTitle: "This alert view has buttons")

    }
   
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    @IBAction func tappedScreen(_ sender: Any) {
        reminderNameTF.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func eventCreate(_ sender: Any) {
        self.sendData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func sendData()
    {
        let newReminderRef = self.ref
            .child("master-reminder")
            .childByAutoId()
        
        let date = reminderDatePicker.date

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        
        formatter.dateFormat = "yyyy"
        let yearStr = formatter.string(from: date)
        formatter.dateFormat = "MM"
        let monthStr = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let dayStr = formatter.string(from: date)
        formatter.dateFormat = "HH"
        let hourStr = formatter.string(from: date)
        
        formatter.dateFormat = "mm"
        let minStr = formatter.string(from: date)
        
        let newRemindertId = newReminderRef.key
        let newRemindertData:[String: AnyObject]  = [
            "reminder_id": newRemindertId as AnyObject,
            "reminder_name":self.reminderNameTF.text as AnyObject,
            "reminder_details":"" as AnyObject,
            "reminder_ownerID": universalUserID as AnyObject ,
            "reminder_time": ["reminder_year":yearStr as AnyObject, "reminder_month":monthStr as AnyObject, "reminder_day":dayStr as AnyObject, "reminder_hour":hourStr as AnyObject, "reminder_minute":minStr as AnyObject, "reminder_second":"00", "reminder_zone":"PDT"] as AnyObject,
            "reminder_recipient": [self.singleRecipient] as AnyObject
        ]
        
        newReminderRef.setValue(newRemindertData)
        self.makeRequest(reminderID: newRemindertId)
        print("data sent")
    }

    func makeRequest(reminderID: String){
        print("making new request")
        let url = "https://still-taiga-45670.herokuapp.com"
        print("\(reminderID)")
        Alamofire.request(url + "?id=" + reminderID).responseJSON { response in
            if let data = response.data, let dataString = String(data: data, encoding: .utf8) {
                print("Result: " + dataString)
                print(url + "?id=" + reminderID)
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
