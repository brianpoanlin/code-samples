//
//  SignInViewController.swift
//  Auxilium
//
//  Created by Brian Lin on 2/4/17.
//  Copyright © 2017 Brian Lin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import OneSignal
import FirebaseDatabase

class SignInViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet var tapper: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
    @IBAction func tapped(_ sender: Any) {
        username.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser != nil {
            print("user is signed in")
            let UID = FIRAuth.auth()?.currentUser?.uid

            let newPth = FIRDatabase.database().reference().child("users/").child(UID!)
            
            var playerID="0"
            
            print(newPth)
            
            OneSignal.idsAvailable({(_ userId, _ pushToken) in
                print("UserId:\(userId)")
                playerID = userId!
                newPth.child("player_id").setValue(userId)

                if pushToken != nil {
                    print("pushToken:\(pushToken)")
                }
            })
            
//            let newPlayerID:[String: String]  = [
//                "playerID": playerID]
            
            

            self.performSegue(withIdentifier: "toMainView", sender: nil)
            
        } else {
            print("user is NOT signed in")
            // ...
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedSignIn(_ sender: Any) {
        FIRAuth.auth()?.signIn(withEmail: self.username.text!, password: self.password.text!) { (user, error) in
            if user != nil {
                print("sign in successful")
                let newPth = FIRDatabase.database().reference().child((user?.uid)!)
                
                var playerID="0"
                
                OneSignal.idsAvailable({(_ userId, _ pushToken) in
                    print("UserId:\(userId)")
                    playerID = userId!
                    if pushToken != nil {
                        print("pushToken:\(pushToken)")
                    }
                })
                
                
                let newPlayerID:[String: String]  = [
                    "playerID": playerID]
                
                
                newPth.setValue(newPlayerID)
                
                self.performSegue(withIdentifier: "toMainView", sender: nil)
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
