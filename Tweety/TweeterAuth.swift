//
//  TweeterAuth.swift
//  Tweety
//
//  Created by Hardik on 20/03/16.
//  Copyright © 2016 Hardik. All rights reserved.
//

import Foundation

public typealias JSONSuccessHandler = (json: JSON, response: NSHTTPURLResponse) -> Void
public typealias FailureHandler = (error: NSError) -> Void
public typealias TokenSuccessHandler = (accessToken: OAuthCredentials?, response: NSURLResponse) -> Void

internal struct CallbackNotification {
    static let notificationName = "SwifterCallbackNotificationName"
    static let optionsURLKey = "SwifterCallbackNotificationOptionsURLKey"
}


class TweeterAuth {
    
    
    public func authorizeAppOnlyWithSuccess(success: TokenSuccessHandler?, failure: FailureHandler?) {
        self.postOAuth2BearerTokenWithSuccess({ json, response in
            if let tokenType = json["token_type"].string {
                if tokenType == "bearer" {
                    let accessToken = json["access_token"].string
                    
                    let credentialToken = SwifterCredential.OAuthAccessToken(key: accessToken!, secret: "")
                    
                    self.client.credential = SwifterCredential(accessToken: credentialToken)
                    
                    success?(accessToken: credentialToken, response: response)
                } else {
                    let error = NSError(domain: "Swifter", code: SwifterError.appOnlyAuthenticationErrorCode, userInfo: [NSLocalizedDescriptionKey: "Cannot find bearer token in server response"]);
                    failure?(error: error)
                }
            } else if let errors = json["errors"].object {
                let error = NSError(domain: SwifterError.domain, code: errors["code"]!.integer!, userInfo: [NSLocalizedDescriptionKey: errors["message"]!.string!]);
                failure?(error: error)
            } else {
                let error = NSError(domain: SwifterError.domain, code: SwifterError.appOnlyAuthenticationErrorCode, userInfo: [NSLocalizedDescriptionKey: "Cannot find JSON dictionary in response"]);
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


    
}
