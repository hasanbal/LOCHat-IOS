//
//  ViewController.swift
//  LOChat
//
//  Created by Hasan Bal on 31.03.2020.
//  Copyright © 2020 bal software. All rights reserved.

import UIKit
import Firebase
//import ChameleonFramework
import CoreLocation


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!


    var anonID = Int.random(in: 1000 ... 9999)
    var curUsername: String! = "anon"
    var locationManager:CLLocationManager!
    var curLatitude: Double = 0.0
    var curLongitude: Double = 0.0
    let RANGE_METER = 1000.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Your random id is: " + String(anonID))
        curUsername = "anon" + String(anonID)
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")
        
        messageTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        
        messageTableView.addGestureRecognizer(tapGesture)
        
        
        configureTableView()
        

        retrieveMessages()
     
        messageTableView.separatorStyle = .none
        
        locationManager = CLLocationManager()
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.requestAlwaysAuthorization()

           if CLLocationManager.locationServicesEnabled(){
               locationManager.startUpdatingLocation()
           }
   
    }


    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.messageDate.text = messageArray[indexPath.row].date
        cell.avatarImageView.image = UIImage(named: "egg")
        
        cell.backgroundColor = UIColor.clear
        
        if cell.senderUsername.text == "anon"+String(anonID) {
            
            //Set background to blue if message is from logged in user.
            cell.avatarImageView.backgroundColor = UIColor(rgb: 0xd8eec3)
            cell.messageBackground.backgroundColor = UIColor(rgb: 0xd8eec3)
            cell.messageDistance.text = "";
            
        } else {
            
            //Set background to grey if message is from another user.
            cell.avatarImageView.backgroundColor = UIColor.white
            cell.messageBackground.backgroundColor = UIColor.white
            cell.messageDistance.text = String(Int(messageArray[indexPath.row].distance)) + "m";
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }

    
    //TODO: Declare configureTableView here:
    
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
        

    }
    
    

    //MARK: - TextField Delegate Methods
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
            self.messageTableView.scrollToBottomRow()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
            self.messageTableView.scrollToBottomRow()
        }
    }

    
    ///////////////////////////////////////////
        //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        curLatitude = userLocation.coordinate.latitude
        curLongitude = userLocation.coordinate.longitude
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")

//        self.labelLat.text = "\(userLocation.coordinate.latitude)"
//        self.labelLongi.text = "\(userLocation.coordinate.longitude)"

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
             //   let placemark = placemarks![0]
//                print(placemark.locality!)
//                print(placemark.administrativeArea!)
//                print(placemark.country!)

//                self.labelAdd.text = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
            }
        }

    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    func getCurrentTime() -> String{
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let date = Date()
        return dateFormatter.string(from: date)
    }
    
    //MARK: - Send & Recieve Messages from Firebase
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        if(messageTextfield.text == nil || messageTextfield.text == ""){
            return;
        }
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
                
        let messagesDB = Database.database().reference().child("messages")
        
        print(getCurrentTime())

        let messageDictionary = ["username": curUsername!,
                                 "message": messageTextfield.text!,
                                 "time":getCurrentTime(),
                                 "latitude":String(curLatitude),
                                 "longitude":String(curLongitude)]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Message saved successfully!")
            }

            self.messageTextfield.isEnabled = true
            self.sendButton.isEnabled = true
            self.messageTextfield.text = ""
            self.messageTableView.scrollToBottomRow()
        
        }
        
        
    }
    
    
    func retrieveMessages() {
        
        let messageDB = Database.database().reference().child("messages")
        
        messageDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            var text = ""
            var sender = ""
            var date = ""
            var latitude = 0.0
            var longitude = 0.0
            
            if(snapshotValue["message"] != nil){
                text = snapshotValue["message"]!
            }
            if(snapshotValue["username"] != nil){
                sender = snapshotValue["username"]!
            }
            if(snapshotValue["time"] != nil){
                date = snapshotValue["time"]!
            }
            if(snapshotValue["latitude"] != nil){
                latitude = Double(snapshotValue["latitude"]!)!
            }
            if(snapshotValue["longitude"] != nil){
                longitude = Double(snapshotValue["longitude"]!)!
            }
            let message = Message()
            let distance = CalculateDistance(lat1: self.curLatitude, lon1: self.curLongitude, lat2: latitude, lon2: longitude);
            
            if(distance <= self.RANGE_METER){
                message.messageBody = text
                message.sender = sender
                message.date = date
                message.distance = distance
                self.messageArray.append(message)
            

                self.configureTableView()
                self.messageTableView.reloadData()
                self.messageTableView.scrollToBottomRow()
            }
     
        
        }
        
    }

    
    ////////////////////////////////////////////////
    
    //MARK - Log Out Method

    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try Auth.auth().signOut()
            
            navigationController?.popToRootViewController(animated: true)
            
        }
        catch {
            print("error: there was a problem logging out")
        }

    }
    


}
