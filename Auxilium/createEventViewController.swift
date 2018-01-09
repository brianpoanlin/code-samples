//
//  createEventViewController.swift
//  Auxilium
//
//  Created by Brian Lin on 2/4/17.
//  Copyright © 2017 Brian Lin. All rights reserved.
//

import UIKit
import MapKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
import Alamofire

class createEventViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventCategory: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var streetNumber: UITextField!
    @IBOutlet weak var locationState: UITextField!
    @IBOutlet weak var locationZip: UITextField!
    var id_to_submit=""
    var hasId = false
    
    @IBOutlet var tap: UITapGestureRecognizer!
    let ref = FIRDatabase.database().reference()
    let eventsRef = FIRDatabase.database().reference(withPath: "master-events")
    
    @IBAction func tapped(_ sender: Any) {
        eventName.resignFirstResponder()
        eventCategory.resignFirstResponder()
        locationName.resignFirstResponder()
        streetNumber.resignFirstResponder()
        locationState.resignFirstResponder()
        locationZip.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if scrollView.contentOffset.y > 200 {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
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

    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendData(lat: Double, withLong:Double)
    {
        let user = FIRAuth.auth()?.currentUser
        let uid = user?.uid

        hasId = true
        
        let dateFormatterMinutes = DateFormatter()
        dateFormatterMinutes.dateFormat = "mm"
        let strDateMin = dateFormatterMinutes.string(from: datePicker.date)
        
        let dateFormatterHour = DateFormatter()
        dateFormatterHour.dateFormat = "hh"
        let strDateHour = dateFormatterHour.string(from: datePicker.date)

        let dateFormatterDate = DateFormatter()
        dateFormatterDate.dateFormat = "MM/dd"
        let strDateDate = dateFormatterDate.string(from: datePicker.date)

        print(strDateDate)
        print(strDateHour)
        print(strDateMin)

        let newEventRef = self.ref
            .child("master-events")
            .childByAutoId()
        
        let newEventId = newEventRef.key
        id_to_submit = newEventId
        let newEventData:[String: AnyObject]  = [
            "event_id": newEventId as AnyObject,
            "event_name":eventName.text as AnyObject,
            "event_description":eventDescription.text! as AnyObject,
            "event_ownerID": uid as AnyObject ,
            "event_time": ["event_date":strDateDate as AnyObject, "event_hour":strDateHour as AnyObject, "event_minute":strDateMin as AnyObject] as AnyObject,
            "event_location":["event_Lat":String(lat) as AnyObject, "event_long":String(withLong) as AnyObject,"event_locName":locationName.text!, "Address": ["street_number":streetNumber.text!,"street_name":streetNumber.text!,"street_city":"San Jose","street_state":locationState.text!, "street_zipcode":locationZip.text!] as AnyObject] as AnyObject,
            "event_category":eventCategory.text! as AnyObject
        ]
        
        print("event id: " + newEventId)
        
        newEventRef.setValue(newEventData)
        
        makeRequest(eventID: newEventId);
        
        let eventVC = self.topMostController().storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        eventVC.toPass = self.id_to_submit
//        self.window?.makeKeyAndVisible()
        self.topMostController().present(eventVC, animated: true, completion: nil)
        
        
    }
    
    func makeRequest(eventID: String){
        print("yOOOO")
        let url = "http://joseph-liu.com:3000/"
        
        Alamofire.request(url + "send/" + eventID).responseJSON { response in
            if let data = response.data, let dataString = String(data: data, encoding: .utf8) {
                print("Result: " + dataString)
            }
        }
    }
    
    
    
    @IBAction func createEvent(_ sender: Any) {
        let address:String = "\(self.streetNumber.text) \(self.locationState.text) \(self.locationZip.text)"
        print("arrived HERE")
        print(address)
        self.addressToCoordinatesConverter(address: address)
    }
    
    func addressToCoordinatesConverter(address: String) {
        print(address)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            if let placemarks:[CLPlacemark] = $0 {
                let latLoc = placemarks[0].location?.coordinate.latitude
                let longLoc = placemarks[0].location?.coordinate.longitude

                print(latLoc!)
                print(longLoc!)
                
                self.sendData(lat: latLoc!, withLong: longLoc!)
            } else {
                print($1)
            }
        }
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if hasId == true {
            let eventView = segue.destination as! EventViewController
            eventView.toPass = self.id_to_submit
        }

        }
        
}
