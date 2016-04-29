//
//  ImageView+Helpers.swift
//  Tweety
//
//  Created by Hardik on 20/03/16.
//  Copyright © 2016 Hardik. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func loadImage(imageUrlString: String, withCompletionHandler block: (() -> Void)? = nil) {
        
        dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
            
            if let imageURL = NSURL(string: imageUrlString) {
                
                if let imageData = NSData(contentsOfURL: imageURL) {
                    let image = UIImage(data: imageData)
                    
                    dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
                        
                        if self == nil {return}
                        
                        self!.image = image
                        
                        if let block = block {
                            block()
                        }
                    }
                }
            }
        }
    }
    
    func makeRound() {
        self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2.0
    }
}