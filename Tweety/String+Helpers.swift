//
//  String+AddOns.swift
//  Tweety
//
//  Created by Hardik on 20/03/16.
//  Copyright © 2016 Hardik. All rights reserved.
//

import Foundation

extension String {
    
    internal func indexOf(sub: String) -> Int? {
        guard let range = self.rangeOfString(sub) where !range.isEmpty else {
            return nil
        }
        return self.startIndex.distanceTo(range.startIndex)
    }
    
    internal subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
            return self[startIndex..<endIndex]
        }
    }
    
    func urlEncodedStringWithEncoding() -> String {
        let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharactersInString("\n:#/?@!$&'()*+,;=")
        allowedCharacterSet.addCharactersInString("[]")
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet)!
        
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
}

