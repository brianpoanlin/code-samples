//
//  SignUpVC.swift
//  Ping
//
//  Created by Brian Lin on 7/16/17.
//  Copyright © 2017 Avinash Jain. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

class SignUpVC: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func tappedScr(_ sender: Any) {
        emailTF.resignFirstResponder()
        firstNameTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
    }

    @IBAction func createAccount(_ sender: Any) {
        
        Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) { (user, error) in
        
            if (error != nil) {
                print("ERROR CREATING ACCT:", error!)
            }
            else {
                print("CREATE ACCT SUCCESS")
                
                if user != nil {
                    print("sign in successful")
                    let newPth = Database.database().reference(withPath: "users").child((user?.uid)!)
                    
                    universalUserID = (user?.uid)!
                    
                    OneSignal.idsAvailable({(_ userId, _ pushToken) in
                        
                        newPth.child("player_id").setValue(userId)
                        newPth.child("user_firstName").setValue(self.firstNameTF.text)
                        
                        print("UserId:\(String(describing: userId))")
                        
                        if pushToken != nil {
                            print("pushToken:\(String(describing: pushToken))")
                        }
                    })
                    
                    self.performSegue(withIdentifier: "s_to_main", sender: nil)
                }
                else{
                    print("sign in failed")
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
