//
//  Colors.swift
//  Coursica
//
//  Created by Regan Bell on 8/5/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Foundation

let coursicaBlue = UIColor(red:31/255.0, green:148/255.0, blue:255/255.0, alpha:1.0)
let greenColor = UIColor(red:31/255.0, green:148/255.0, blue:100/255.0, alpha:1.0)
let yellowColor = UIColor(red:1, green:213/255.0, blue:31/255.0, alpha:1.0)
let redColor = UIColor(red:219/255.0, green:32/255.0, blue:35/255.0, alpha:1.0)

func colorForPercentile(percentile: Int) -> UIColor {
    switch percentile {
    case 90...1000: return coursicaBlue
    case 80...90:   return UIColor(rgba: "#1FD5FF")
    case 70...80:   return UIColor(rgba: "#1FFFA7")
    case 60...70:   return UIColor(rgba: "#59FF1F")
    case 50...60:   return UIColor(rgba: "#9AFF1F")
    case 40...50:   return UIColor(rgba: "#DBFF1F")
    case 30...40:   return UIColor(rgba: "#FFE21F")
    case 20...30:   return UIColor(rgba: "#FFA11F")
    case 10...20:   return UIColor(rgba: "#FF601F")
    case  0...10:   return UIColor(rgba: "#FF1F1F")
    default:        return UIColor(white: 241/255.0, alpha: 1)
    }
}

extension UIColor {
    public convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = advance(rgba.startIndex, 1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (count(hex)) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                println("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}