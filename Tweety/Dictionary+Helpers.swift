//
//  Dictionary+AddOns.swift
//  Tweety
//
//  Created by Hardik on 20/03/16.
//  Copyright © 2016 Hardik. All rights reserved.
//

import Foundation

extension Dictionary {
    
    func filter(predicate: Element -> Bool) -> Dictionary {
        var filteredDictionary = Dictionary()
        for (key, value) in self where predicate(key, value) {
            filteredDictionary[key] = value
        }
        return filteredDictionary
    }
    
    func queryStringWithEncoding() -> String {
        var parts = [String]()
        
        for (key, value) in self {
            let keyString: String = "\(key)"
            let valueString: String = "\(value)"
            let query: String = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        
        return parts.joinWithSeparator("&")
    }
    
    func urlEncodedQueryStringWithEncoding(encoding: NSStringEncoding) -> String {
        var parts = [String]()
        
        for (key, value) in self {
            let keyString: String = "\(key)".urlEncodedStringWithEncoding()
            let valueString: String = "\(value)".urlEncodedStringWithEncoding()
            let query: String = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        
        return parts.joinWithSeparator("&")
    }
}

