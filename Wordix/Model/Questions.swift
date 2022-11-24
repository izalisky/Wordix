//
//  Questions.swift
//  Wordix
//
//  Created by Ігор on 11/4/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift

class Questions: WordixObject {
    @objc dynamic var id : Int = 0
    @objc dynamic var bonus_game_id : Int = 0
    @objc dynamic var question : String = ""
    dynamic var fakeAnswers : List<String> = List<String>()
    @objc dynamic var rightAnswer : String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
      return []
    }
    
    
    func initWithObject(obj:[String:AnyObject]){
        self.id = (obj["id"] as? Int)!
        self.bonus_game_id = (obj["bonus_game_id"] as? Int)!
        self.question = (obj["question"] as? String)!
        self.imageName = (obj["image_name_question"] as? String)!
        self.rightAnswer = (obj["right_answer"] as? String)!
        
        let fa = obj["fake_answers"] as? [String]
        for item in fa! {
            self.fakeAnswers.append(item)
        }
        //self.perform(#selector(chacheImage), with: nil, afterDelay: 10.0)
        chacheImage()
    }
}
