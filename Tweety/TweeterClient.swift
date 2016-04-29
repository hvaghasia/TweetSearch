//
//  TweeterClient.swift
//  Tweety
//
//  Created by Hardik on 20/03/16.
//  Copyright © 2016 Hardik. All rights reserved.
//

import Foundation
import Accounts

let TwitterAccessToken = "accessToken"
let TwitterExpDate = "token_expiry_date"

public typealias JSONSuccessHandler = (json: AnyObject, response: NSHTTPURLResponse) -> Void
public typealias FailureHandler = (error: NSError) -> Void

public typealias TokenSuccessHandler = (accessToken: TweeterCredentials?, response: NSURLResponse) -> Void


public class TweeterClient {
    
    internal struct MyTweeterErrorDomain {
        static let domain = "MyTweeterErrorDomain"
        static let appOnlyAuthenticationErrorCode = 1
    }
    
    // MARK: - Properties
    
    let apiURL = NSURL(string: "https://api.twitter.com/1.1/")!
    var client: TweeterAppOnlyClient?
    
    // MARK: - Initializers
    
    public init(consumerKey: String, consumerSecret: String) {
        self.client = TweeterAppOnlyClient(consumerKey: consumerKey, consumerSecret: consumerSecret)
    }
    
    deinit {
        print("DeInit")
    }
    
    // MARK: - JSON Requests
    
    internal func jsonRequestWithPath(path: String, baseURL: NSURL, method: HTTPMethodType, parameters: Dictionary<String, Any>,  downloadProgress: JSONSuccessHandler? = nil, success: JSONSuccessHandler? = nil, failure: TweeterHTTPRequest.FailureHandler? = nil) -> TweeterHTTPRequest {
        let jsonDownloadProgressHandler: TweeterHTTPRequest.DownloadProgressHandler = { data, _, _, response in
            
            guard downloadProgress != nil else { return }
            
            if let jsonResult = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) {
                downloadProgress?(json: jsonResult, response: response)
            } else {
                let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
                let jsonChunks = jsonString!.componentsSeparatedByString("\r\n") as [String]
                
                for chunk in jsonChunks where !chunk.utf16.isEmpty {
                    if let chunkData = chunk.dataUsingEncoding(NSUTF8StringEncoding),
                        let jsonResult = try? NSJSONSerialization.JSONObjectWithData(chunkData, options: .AllowFragments) {
                            downloadProgress?(json: jsonResult, response: response)
                    }
                }
            }
        }
        
        let jsonSuccessHandler: TweeterHTTPRequest.SuccessHandler = { data, response in
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
                do {
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    dispatch_async(dispatch_get_main_queue()) {
                        success?(json: jsonResult, response: response)
                    }
                } catch let error as NSError {
                    dispatch_async(dispatch_get_main_queue()) {
                        failure?(error: error)
                    }
                }
            }
        }
        
        if method == .GET {
            return self.client!.get(path, baseURL: baseURL, parameters: parameters, downloadProgress: jsonDownloadProgressHandler, success: jsonSuccessHandler, failure: failure)
        }
        else {
            return self.client!.post(path, baseURL: baseURL, parameters: parameters, downloadProgress: jsonDownloadProgressHandler, success: jsonSuccessHandler, failure: failure)
        }
    }
    
    public func authorizeAppOnlyWithSuccess(success: TokenSuccessHandler?, failure: FailureHandler?) {
        
        self.postOAuth2BearerTokenWithSuccess({ json, response in
            
            let dict = json as! NSDictionary
            print("dictionary : \(dict)")
            
            if let tokenType = json["token_type"] as? String {
                if tokenType == "bearer" {
                    let accessToken = json["access_token"] as? String
                                        
                    self.client!.credential = TweeterCredentials(token: accessToken!)
                    self.cacheAccessToken()
                    
                    success?(accessToken: self.client!.credential, response: response)
                } else {
                    let error = NSError(domain: "Tweety", code: MyTweeterErrorDomain.appOnlyAuthenticationErrorCode, userInfo: [NSLocalizedDescriptionKey: "Cannot find bearer token in server response"]);
                    failure?(error: error)
                }
            } else if let errors = json["errors"] as? NSDictionary, let code = errors["code"] as? Int {
                let error = NSError(domain: MyTweeterErrorDomain.domain, code: code, userInfo: [NSLocalizedDescriptionKey: errors["message"]!.string!]);
                failure?(error: error)
            } else {
                let error = NSError(domain: MyTweeterErrorDomain.domain, code: MyTweeterErrorDomain.appOnlyAuthenticationErrorCode, userInfo: [NSLocalizedDescriptionKey: "Cannot find JSON dictionary in response"]);
                failure?(error: error)
            }
            
            }, failure: failure)
    }
    
    public func postOAuth2BearerTokenWithSuccess(success: JSONSuccessHandler?, failure: FailureHandler?) {
        let path = "/oauth2/token"
        
        var parameters = Dictionary<String, Any>()
        parameters["grant_type"] = "client_credentials"
        
        self.jsonRequestWithPath(path, baseURL: self.apiURL, method: .POST, parameters: parameters, success: success, failure: failure)
    }
    
    public func getSearchTweetsWithQuery(q: String, count: Int? = nil, sinceID: String? = nil, resultType: String? = nil,success: ((statuses: [AnyObject]?, searchMetadata: Dictionary<String, AnyObject>?) -> Void)? = nil, failure: FailureHandler) {
                                            
        let path = "search/tweets.json"
        
        var parameters = Dictionary<String, Any>()
        parameters["q"] = q
        parameters["count"] = count
        parameters["result_type"] = resultType
        parameters["since_id"] = sinceID
        
        print("Tweet count : \(count)")
        print("Tweet since_id : \(sinceID)")
        
        self.jsonRequestWithPath(path, baseURL: self.apiURL, method: .GET, parameters: parameters, success: { json, _ in
            
            if let status = json["statuses"] as? [AnyObject], let metadata = json["search_metadata"] as? Dictionary<String, AnyObject> {
                success?(statuses: status, searchMetadata: metadata)
            }
            
            }, failure: failure)
    }
    
    func cacheAccessToken() {
        // store credentials
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(self.client!.credential?.authToken, forKey: TwitterAccessToken)
        userDefaults.synchronize()
    }
    
    func logOut() {
        // Clear credentials
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(TwitterAccessToken)
        userDefaults.synchronize()
    }
    
    func accessToken() -> String? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let accessToken = userDefaults.valueForKey(TwitterAccessToken) as? String {
            self.client!.credential = TweeterCredentials(token: accessToken)
            return accessToken
        }

        return nil
    }
}

