//
//  LookUpUserIdVC.swift
//  Ping
//
//  Created by Brian Lin on 7/13/17.
//  Copyright © 2017 Avinash Jain. All rights reserved.
//

import UIKit
import Firebase

class LookUpUserIdVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    let ref = Database.database().reference()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.makeFriends()
        // Do any additional setup after loading the view.
    }

    func makeFriends() {
        let friendsPath = Database.database().reference(withPath: "users").child(universalUserID).child("friends")
        
        let newPostRef = friendsPath.childByAutoId();
        newPostRef.setValue("e8GRXmBTPTg6pkUmSo8sOp70VeP3")
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminder", for: indexPath)
      
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
