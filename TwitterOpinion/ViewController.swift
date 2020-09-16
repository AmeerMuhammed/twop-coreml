//
//  ViewController.swift
//  TwitterOpinion
//
//  Created by AmeerMuhammed on 9/10/20.
//  Copyright © 2020 AmeerMuhammed. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    struct APISecret: Codable {
        var API_KEY:String
        var API_SECRET:String
    }
    
    var swifter : Swifter?
    
    @IBOutlet weak var sentientLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    let tweetCount = 100
    
    let sentimentClassifier = TwitterSentimentClassifier()
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func predictOpinion(_ sender: Any) {
        initSwifter()
        fetchAPI()
    }
    
    
    func initSwifter() {
        if  let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
            let file = FileManager.default.contents(atPath: path),
            let secrets = try? PropertyListDecoder().decode(APISecret.self, from: file)
        {
            self.swifter = Swifter(consumerKey: secrets.API_KEY, consumerSecret: secrets.API_SECRET)
        }
    }
    
    func fetchAPI() {
        if let text = textField.text {
        swifter?.searchTweet(using: text, lang:"en", count:tweetCount,tweetMode: .extended, success: { (results, metadata) in
            var tweets = [TwitterSentimentClassifierInput]()
            for i in 0..<self.tweetCount {
                if let tweet = results[i]["full_text"].string {
                    tweets.append(TwitterSentimentClassifierInput(text: tweet))
                }
            }
            do{
                let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
                
                var score: Int = 0
                
                for  prediction in predictions {
                    switch prediction.label {
                    case "Pos":
                        score += 1
                    case "Neg":
                        score -= 1
                    default:
                        break
                    }
                }
                
                switch score {
                case 20... :
                    self.sentientLabel.text = "😍"
                case 10 ..< 20:
                    self.sentientLabel.text = "😁"
                case 1 ..< 10:
                    self.sentientLabel.text = "☺️"
                case 0:
                    self.sentientLabel.text = "😐"
                case -10 ..< 0:
                    self.sentientLabel.text = "🤥"
                case -19 ..< -10:
                    self.sentientLabel.text = "😡"
                case  -100 ... -20:
                    self.sentientLabel.text = "🤮"
                default:
                    break
                }
                print(score)
                
            } catch {
                print(error)
            }
            
        }, failure: { (error) in
            print(error)
        })
    }
    }
}

