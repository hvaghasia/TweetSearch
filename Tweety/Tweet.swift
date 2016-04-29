//
//  Tweet.swift
//  Tweety
//
//  Created by Hardik on 20/03/16.
//  Copyright © 2016 Hardik. All rights reserved.
//

import Foundation


struct Tweet {
    
    var tweet: String?
    var userName: String?
    var userProfileImageUrl: String?
    var id: String?
    
    init(tweetInfo: AnyObject) {
        
        if let txt = tweetInfo["text"] as? String {
            tweet = txt
        }
        
        if let tweetId = tweetInfo["id_str"] as? String {
            id = "\(tweetId)"
        }
        
        if let usr = tweetInfo["user"] as? NSDictionary {
            if let usrName = usr["name"] as? String {
                userName = usrName
            }
            
            if let userImageUrl = usr["profile_image_url_https"] as? String {
                userProfileImageUrl = userImageUrl
            }
        }
    }
}