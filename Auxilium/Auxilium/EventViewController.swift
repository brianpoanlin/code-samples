//
//  EventViewController.swift
//  Auxilium
//
//  Created by Brian Lin on 2/4/17.
//  Copyright © 2017 Brian Lin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MapKit



class EventViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var dspText: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    var lat:Double = 0.0
    var long:Double = 0.0
    var LocationName:String = ""
    
    var toPass:String!
    let eventsRef = FIRDatabase.database().reference(withPath: "master-events/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("passed \(toPass)")
        mapView.delegate = self
        eventName.adjustsFontSizeToFitWidth = true;
        self.pullData()
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)

      
    
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func pullData(){
        
        eventsRef.child(toPass).observe(FIRDataEventType.value, with: { (snapshot) in
            let event = snapshot.value as? [String : AnyObject] ?? [:]
            let eventDict = event as NSDictionary
            self.eventName.text = eventDict.value(forKey: "event_name") as! String?
            let imgStr = eventDict.value(forKey: "event_category") as! String
            self.iconImg.image = UIImage(named: "\(imgStr).png")
            self.dspText.text = eventDict.value(forKey: "event_description") as! String?
            let corrdinates:NSDictionary = eventDict.object(forKey: "event_location") as! NSDictionary
            let latLoc:Double = ((corrdinates.value(forKey: "event_Lat") as? NSString)?.doubleValue)!
            let longLoc:Double = ((corrdinates.value(forKey: "event_long") as? NSString)?.doubleValue)!
            self.lat = latLoc
            self.long = longLoc
            let locNameLocal:String = corrdinates.value(forKey: "event_locName") as! String
            self.LocationName = locNameLocal
            
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = CLLocationCoordinate2DMake(self.lat, self.long)
            dropPin.title = self.LocationName
            self.mapView.addAnnotation(dropPin)
            self.mapView.selectAnnotation(dropPin, animated: true)
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)

        })
        
    }
    
    @IBAction func tappedMaps(_ sender: Any) {
        print("tapped")
        let coordinate = CLLocationCoordinate2DMake(lat,long)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = LocationName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
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
