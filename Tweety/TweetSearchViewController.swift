//
//  TweetSearchViewController.swift
//  Tweety
//
//  Created by Hardik on 19/03/16.
//  Copyright © 2016 Hardik. All rights reserved.
//

import UIKit

let TwitterConsumerKey = "o1I3NkiJOkgBqQdAyIqSuExEj"
let TwitterConsumerSecret = "uauY7Sny3fdakz4U2qXlC6g6QKKuzFRKgWvcwet08AuDUnrPSf"
let TweetFeedPollingTimeInterval: NSTimeInterval = 5

class TweetSearchViewController: UITableViewController {

    private var twitterClient: TweeterClient
    private var tweets = [Tweet]()
    private var oldSearchTerm: String = ""
    private var pollTimer: NSTimer?
    private var isAutoFetchRunning = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        self.twitterClient = TweeterClient(consumerKey: TwitterConsumerKey, consumerSecret: TwitterConsumerSecret)
        super.init(coder: aDecoder)
    }
    
    // MARK: View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        refreshControl?.addTarget(self, action: "refreshTweetFeed:", forControlEvents: .ValueChanged)
        
        // Get access token from Twitter if not available
        if let _ = twitterClient.accessToken() {
//            oldSearchTerm = "Test"
//            loadTweets()
        } else {
            getAccessToken()
        }
    }
    
    // MARK: Custom methods
    private func getAccessToken() {
        
        twitterClient.authorizeAppOnlyWithSuccess({ (accessToken, response) -> Void in
            print("accessToken : \(accessToken)")
            
            }) { (error) -> Void in
                print("Error : \(error.userInfo)")
        }
    }
    
    private func loadTweets(forSearchTerm searchTerm: String? = "Test") {
        
        if let searchString = searchTerm where canSearch {
            
            var sinceId: String?
            var tweetCount = 50 // Initial fetch count is 50
            if searchString == oldSearchTerm {
                sinceId = mostRecentTweet()?.id
                tweetCount = 5 // For auto fetch, we will bring 5 tweets at a time
            }
            
            // Get tweets from twitter using REST api
            self.twitterClient.getSearchTweetsWithQuery(searchString, count: tweetCount, sinceID: sinceId, resultType: "recent",success: { [weak self] (statuses: [AnyObject]?, searchMetadata: Dictionary<String, AnyObject>?) in
                
                guard let weakSelf = self else {return}
                
                if searchString != weakSelf.oldSearchTerm {
                    weakSelf.tweets.removeAll()
                    weakSelf.tableView.reloadData()
                }
                
                if let tweets = statuses {
                    
                    var tweetsObjects = [Tweet]()
                    for tweet in tweets {
                        tweetsObjects.append(Tweet(tweetInfo: tweet))
                    }
                    
                    weakSelf.insertNewTweets(tweetsObjects)
                }
                
                weakSelf.oldSearchTerm = searchString
                weakSelf.startTimerForAutoFetch()
                weakSelf.refreshControl?.endRefreshing()
                
                }, failure: { [weak self] (error) -> Void in
                    
                    print("Get Twitts error : \(error.userInfo)")
                    
                    guard let weakSelf = self else {return}

                    if weakSelf.refreshControl?.refreshing == true {
                        weakSelf.refreshControl?.endRefreshing()
                    }
                })
            
        } else {
            print("Search Term is Empty")
            
            if refreshControl?.refreshing == true {
                refreshControl?.endRefreshing()
            }
        }
    }
    
    private func insertNewTweets(tweetObjects: [Tweet]) {
        
        var insertedIndexPaths = [NSIndexPath]()
        for (index, _) in tweetObjects.enumerate() {
            insertedIndexPaths.append(NSIndexPath(forRow: index, inSection: 0))
        }
        tweets.insertContentsOf(sortTweets(tweetObjects), at: 0)

        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(insertedIndexPaths, withRowAnimation: .Top)
        tableView.endUpdates()
    }

    private func mostRecentTweet() -> Tweet? {
        
        if tweets.isEmpty == false {
            let mostRecentTweet = tweets.reduce(tweets[0], combine: { Int($0.id!) > Int($1.id!) ? $0 : $1 } )
            return mostRecentTweet
        }
        return nil
    }
    
    private func sortTweets(tweetObjects: [Tweet]) -> [Tweet] {
        
        return tweetObjects.sort({ Int($0.id!) > Int($1.id!)})
    }
    
    private func startTimerForAutoFetch() {
        
        guard let timer = pollTimer else {
            scheduleTimer()
            return
        }
        
        if timer.valid == false && isAutoFetchRunning {
            scheduleTimer()
        }
    }
    
    private func scheduleTimer() {
        pollTimer =  NSTimer.scheduledTimerWithTimeInterval(TweetFeedPollingTimeInterval, target: self, selector: Selector("refreshTweetFeed:"), userInfo: nil, repeats: true)
    }
    
    func refreshTweetFeed(sender: AnyObject) {
        loadTweets(forSearchTerm: searchBar.text)
    }
    
    private var canSearch: Bool {
        if let text = searchBar.text where text.trim().characters.count > 0 {
            return true
        }
        return false
    }
    
    func updateAutoFetchOnOffButtonState() {
        
        if canSearch {
            isAutoFetchRunning = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: "autoFetchOnOffButtonTapped:")
        } else {
            isAutoFetchRunning = false
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    func autoFetchOnOffButtonTapped(barButton: UIBarButtonItem) {
        
        if isAutoFetchRunning {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "autoFetchOnOffButtonTapped:")
            pollTimer?.invalidate()
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: "autoFetchOnOffButtonTapped:")
            startTimerForAutoFetch()
        }
        
        isAutoFetchRunning = !isAutoFetchRunning
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Clean up some old tweets
        if tweets.count > 200 {
            tweets.removeRange(Range(start: tweets.count - 100, end: tweets.count - 1))
        } else if tweets.count > 100 {
            tweets.removeRange(Range(start: tweets.count - 50, end: tweets.count - 1))
        } else if tweets.count > 50 {
            tweets.removeRange(Range(start: tweets.count - 20, end: tweets.count - 1))
        }
        tableView.reloadData()
    }
}

// MARK: - Table View methods

extension TweetSearchViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetsCell", forIndexPath: indexPath) as! TweetsTableViewCell
        let tweet = tweets[indexPath.row]
        cell.configureWithTweetData(tweet)
        return cell
    }
}

// MARK: - UISearchBar Delegate

extension TweetSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        loadTweets(forSearchTerm: searchBar.text)
        updateAutoFetchOnOffButtonState()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if canSearch == false {
            searchBar.resignFirstResponder()
            pollTimer?.invalidate()
            updateAutoFetchOnOffButtonState()
        }
    }
}


