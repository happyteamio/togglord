//
//  Extensions.swift
//  togglord
//
//  Created by Maciej Woźniak on 13.02.2018.
//  Copyright © 2018 happyteam.io. All rights reserved.
//

import Foundation

extension String {
    func toBase64() -> String {
        let data = self.data(using: String.Encoding.utf8)
        return data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
}

extension Calendar {
    func firstDateOfTheWeek(week: Date) -> Date {
        let currentDateComponents = dateComponents([.yearForWeekOfYear, .weekOfYear ], from: week)
        let startOfWeek = date(from: currentDateComponents)
        return startOfWeek!
    }
}
