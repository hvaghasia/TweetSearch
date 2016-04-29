//
//  TweetsTableViewCell.swift
//  Tweety
//
//  Created by Hardik on 20/03/16.
//  Copyright © 2016 Hardik. All rights reserved.
//

import Foundation
import UIKit

class TweetsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    
    func configureWithTweetData(tweetData: Tweet) {
        userNameLabel.text = tweetData.userName
        tweetLabel.text = tweetData.tweet
        userProfileImageView.image = nil
        userProfileImageView.makeRound()
        userProfileImageView.clipsToBounds = true
        if let profileImageUrl = tweetData.userProfileImageUrl {
            userProfileImageView.loadImage(profileImageUrl)
        }
    }
}