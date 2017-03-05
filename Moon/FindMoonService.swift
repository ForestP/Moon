//
//  FindMoonService.swift
//  Moon
//
//  Created by Forest Plasencia on 3/3/17.
//  Copyright © 2017 Forest Plasencia. All rights reserved.
//

import Foundation

protocol FindMoonServiceDelegate: class {
    
}

class FindMoonService {
    private static let _instance = FindMoonService()
    
    weak var delegate: FindMoonServiceDelegate?
    
    static var instance: FindMoonService {
        return _instance
    }

    func jdFromDate(date : NSDate) -> Double {
        let JD_JAN_1_1970_0000GMT = 2440587.5
        return JD_JAN_1_1970_0000GMT + date.timeIntervalSince1970 / 86400
    }
    
    func findMoon(date: NSDate, longitude: Double, latitude: Double) -> (Double,Double,Double){
        
        
        func toRad(degree: Double) -> Double {
            let rad = degree * M_PI/180
            return rad
        }
        func toDegree(rad: Double) -> Double {
            let degree = rad * 180/M_PI
            return degree
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        var d = jdFromDate(date: date) - 2451545
        print("date: \(d)")
        
        // Users' long / lat
//        let longitude = longitude
//        let latitude = latitude
        
        // let lo_rad = toRad(degree: longitude)
        let la_rad = toRad(degree: latitude)
        
        
        
        //Mean position of Moon
        
        var L = 218.316 + (13.176396 * d)   // Ecliptic Longitude
        var M = 134.963 + (13.064993 * d)   // Mean Anomaly
        var F = 93.272 + (13.229350 * d)    // Mean Distance
        
        // Normalize degree
        L = L.truncatingRemainder(dividingBy: 360)
        M = M.truncatingRemainder(dividingBy: 360)
        F = F.truncatingRemainder(dividingBy: 360)
        
        // convert to rad
        L = toRad(degree: L)
        M = toRad(degree: M)
        F = toRad(degree: F)
        
        // Position of Moon
        let l = L + (toRad(degree: 6.289) * sin(M)) // Ecliptic Longitude
        let b = toRad(degree: 5.128) * sin(F)       // Ecliptic Latitude
        let dt = 385001 - (20905 * cos(M))          // Ecliptic Distance
        
        // convert to degree
        let l_deg = toDegree(rad: l)
        //  print("Ecliptic Long: \(l_deg)")
        let b_deg = toDegree(rad: b)
        //     print("Ecliptic Lat: \(b_deg)")
        
        
        // Declination and Right Ascension
        let e = toRad(degree:23.4397)
        let declination = sin(sin(b) * cos(e) + cos(b) * sin(e) * sin(l)) // Declination
        //  print("Declination: \(toDegree(rad: declination))")
        let ra = atan2(sin(l)*cos(e) - tan(b)*sin(e),cos(l))
        // print("ra : \(toDegree(rad: ra))")
        
        let T = (d)/36525.0
        var theta0 = 280.46061837 + 360.98564736629*(d) + 0.000387933*T*T - T*T*T/38710000.0
        theta0 = theta0.truncatingRemainder(dividingBy: 360) // normalize degree
        var theta = theta0 + longitude // theta0 + users' longitude
        theta = toRad(degree: theta) // convert theta to radian
        
        let H = theta - ra // Calculate hour angle
        // print(toDegree(rad: H))
        
        var h = asin(sin(la_rad)*sin(declination) + cos(la_rad)*cos(declination)*cos(H))
        var hTemp = 0.0
        if (h > 0){
            hTemp = h
        }
        let hRefrac = 0.0002967 / tan(hTemp + 0.00312536 / (hTemp + 0.08901179))
        h = h + hRefrac
        
        // let pa = atan2(sin(H), tan(la_rad) * cos(declination) - sin(declination) * cos(H))
        h = h + hRefrac
        
        var A = atan2(sin(H), cos(H) * sin(la_rad) - tan(declination) * cos(la_rad))
        h = toDegree(rad: h) // Convert height back to degrees to be returned
        A = 180 + toDegree(rad: A) // convert azimuth back to degrees to be returned
        
        
        //TO DO SET OVERLAY
        //setMoonOverlay(altitude: h)
        

        
        return (h, A, dt)
    }



}
