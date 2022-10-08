//
//  Date+.swift
//  Layer
//
//  Created by 박진서 on 2022/10/06.
//

import Foundation

extension Date {
    var second: Int {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "ss"
        return Int(formatter.string(from: self))!
    }
    
    var minute: Int {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "mm"
        return Int(formatter.string(from: self))!
    }
    
    var hour: Int {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "HH"
        return Int(formatter.string(from: self))!
    }
    
    var day: Int {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd"
        return Int(formatter.string(from: self))!
    }
    
    var month: Int {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MM"
        return Int(formatter.string(from: self))!
    }
    
    var year: Int {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy"
        return Int(formatter.string(from: self))!
    }
    
    var dateTime: String {
        return parseNumber(number: year) + "/" + parseNumber(number: month) + "/" + parseNumber(number: day) + "T" + parseNumber(number: hour) + ":" + parseNumber(number: minute) + ":" + parseNumber(number: second)
    }
    
    func after(day: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: day, to: Date())!
        return date.dateTime
    }
    
    private func parseNumber(number: Int) -> String {
        if "\(number)".count == 1 {
            return "0\(number)"
        }
        return "\(number)"
    }
}
