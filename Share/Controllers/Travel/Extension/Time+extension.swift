//
//  Time+extension.swift
//  Share
//
//  Created by Dominique Michael Abejar on 05/11/2018.
//  Copyright © 2018 Caryl Rabanos. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    static func calculateDate(hour: Int, minute: Int) -> Date{
        let formater = DateFormatter()
        formater.dateFormat = "h:mm a"
        formater.locale = Locale(identifier: "en_US_POSIX")
        formater.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let calculatedDate = formater.date(from: "\(hour):\(minute)")
        return calculatedDate!
    }
    func getTime() -> (hour:Int, minute:Int,Time: String){
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let time = "\(hour) : \(minute)"
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "HH:mm"
        let date = dateFormater.date(from: time)
        dateFormater.dateFormat = "h:mm a"
        let Date12 = dateFormater.string(from: date!)
        return (hour,minute,Date12)
    }
}
