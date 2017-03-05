//
//  ViewController.swift
//  Moon
//
//  Created by Forest Plasencia on 3/3/17.
//  Copyright © 2017 Forest Plasencia. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var overlayImg: UIImageView!
    @IBOutlet weak var earthImg: UIImageView!
    
    @IBOutlet weak var viewContainer: UIView!
    
    var lm: CLLocationManager!

    let fm = FindMoonService.instance


    var date = NSDate()
    var angle: CGFloat?
    let rad = CGFloat(3.14159/180)
    
    var moonFound = false
    var setMoon = false
    var moonAzimuth: CGFloat?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        lm = CLLocationManager()
        lm.delegate = self
        
        // Core Location Manager asks for GPS location
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.requestWhenInUseAuthorization()
        lm.startMonitoringSignificantLocationChanges()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
            lm.requestWhenInUseAuthorization()
        }
            
            
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways)
        {
            print(self.lm.location)
            
            print("Location Authorized!")
            lm.startUpdatingHeading()

            // Starts timer to check for moon position every 60 seconds
            findMoonThread()
            var _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.findMoonThread), userInfo: nil, repeats: true);
            
        } else {
            print("Location not authorized")
            
            // TODO OPEN ALERT
        }
    
        
        
        
    }
    
    func findMoonThread() {
        if let latitude = (self.lm.location?.coordinate.latitude) as Double?,
            let longitude = (self.lm.location?.coordinate.longitude) as Double? {
            
            DispatchQueue.global(qos: .userInteractive).async {
                // do some task
                let moonData = self.fm.findMoon(date: self.date, longitude: longitude, latitude: latitude)

                DispatchQueue.main.async {
                    // update some UI
                    let azimuth = CGFloat(moonData.1)
                    let altitude = moonData.0
                    let moonDistance = moonData.2
                    
                    self.moonAzimuth = azimuth
                    self.moonFound = true
                    print("SET MOON")
                    // set rotation of moon overlay
                    
                    
                    let rotationAngle = (azimuth * self.rad)
                    self.overlayImg.transform = CGAffineTransform(rotationAngle: rotationAngle)
                    

                }
            }
        }
    }
    

    
    // Called when heading changes
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading ) {
        
        
        // Set rotation of Earth img from heading
        let currentHeading = CGFloat(newHeading.trueHeading)
        // Points to North
        let viewAngle = (0 - (self.rad * currentHeading))
        self.viewContainer.transform = CGAffineTransform(rotationAngle: viewAngle)
        

        
        
        
    }



}

