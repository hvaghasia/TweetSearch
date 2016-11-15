//
//  NSUrl+AddOns.swift
//  Tweety
//
//  Created by Hardik on 20/03/16.
//  Copyright © 2016 Hardik. All rights reserved.
//

import Foundation


extension NSURL {
    
    func appendQueryString(queryString: String) -> NSURL {
        guard !queryString.utf16.isEmpty else {
            return self
        }
        
        var absoluteURLString = self.absoluteString
        
        if absoluteURLString!.hasSuffix("?") {
            absoluteURLString = absoluteURLString![0 ..< absoluteURLString!.utf16.count]
        }
        
        let URLString = absoluteURLString! + (absoluteURLString!.rangeOfString("?") != nil ? "&" : "?") + queryString
        return NSURL(string: URLString)!
    }
    
}
