//
//  TweeterCredentials.swift
//  Tweety
//
//  Created by Hardik on 20/03/16.
//  Copyright © 2016 Hardik. All rights reserved.
//

import Foundation

public struct TweeterCredentials {
    
    var authToken: String
    
    public init(token: String) {
        self.authToken = token
    }
}

