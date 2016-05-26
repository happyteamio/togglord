//
//  Extensions.swift
//  togglord
//
//  Created by Maciej Woźniak on 24.04.2016.
//  Copyright © 2016 Happy Team. All rights reserved.
//

import Foundation

extension String {
    func toBase64() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
}

extension NSCalendar {
    func firstDateOfTheWeek(week: NSDate) -> NSDate {
        let currentDateComponents = components([.YearForWeekOfYear, .WeekOfYear ], fromDate: week)
        let startOfWeek = dateFromComponents(currentDateComponents)
        return startOfWeek!
    }
}