//
//  TwitterAppOnlyClient.swift
//  Tweety
//
//  Created by Hardik on 20/03/16.
//  Copyright © 2016 Hardik. All rights reserved.
//

import Foundation

class TweeterAppOnlyClient  {
    
    var consumerKey: String
    var consumerSecret: String
    
    var credential: TweeterCredentials?
    
    init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }
    
    func get(path: String, baseURL: NSURL, parameters: Dictionary<String, Any>, downloadProgress: TweeterHTTPRequest.DownloadProgressHandler?, success: TweeterHTTPRequest.SuccessHandler?, failure: TweeterHTTPRequest.FailureHandler?) -> TweeterHTTPRequest {
        let url = NSURL(string: path, relativeToURL: baseURL)
        
        let request = TweeterHTTPRequest(URL: url!, method: .GET, parameters: parameters)
        request.downloadProgressHandler = downloadProgress
        request.successHandler = success
        request.failureHandler = failure
        
        if let bearerToken = self.credential?.authToken {
            request.headers = ["Authorization": "Bearer \(bearerToken)"];
        }
        
        request.start()
        return request
    }
    
    func post(path: String, baseURL: NSURL, parameters: Dictionary<String, Any>, downloadProgress: TweeterHTTPRequest.DownloadProgressHandler?, success: TweeterHTTPRequest.SuccessHandler?, failure: TweeterHTTPRequest.FailureHandler?) -> TweeterHTTPRequest {
        let url = NSURL(string: path, relativeToURL: baseURL)
        
        let request = TweeterHTTPRequest(URL: url!, method: .POST, parameters: parameters)
        request.downloadProgressHandler = downloadProgress
        request.successHandler = success
        request.failureHandler = failure
        
        if let bearerToken = self.credential?.authToken {
            request.headers = ["Authorization": "Bearer \(bearerToken)"];
        } else {
            let basicCredentials = TweeterAppOnlyClient.base64EncodedCredentialsWithKey(self.consumerKey, secret: self.consumerSecret)
            request.headers = ["Authorization": "Basic \(basicCredentials)"];
            request.encodeParameters = true
        }
        
        request.start()
        return request
    }
    
    class func base64EncodedCredentialsWithKey(key: String, secret: String) -> String {
        let encodedKey = key.urlEncodedStringWithEncoding()
        let encodedSecret = secret.urlEncodedStringWithEncoding()
        let bearerTokenCredentials = "\(encodedKey):\(encodedSecret)"
        if let data = bearerTokenCredentials.dataUsingEncoding(NSUTF8StringEncoding) {
            return data.base64EncodedStringWithOptions([])
        }
        return String()
    }
    
}
