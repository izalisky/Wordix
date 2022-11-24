//
//  Bonus.swift
//  Wordix
//
//  Created by Ігор on 11/3/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift

class Bonus: WordixObject {
    
    
    @objc dynamic var id : Int = 0
    @objc dynamic var levelNumber : Int = 0
    @objc dynamic var title : String = ""
    @objc dynamic var subtitle : String = ""
    @objc dynamic var languageID : Int = 0
    @objc dynamic var created_at : String = ""
    @objc dynamic var updated_at : String = ""
    
    dynamic var questions : List<Questions> = List<Questions>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
      return []
    }
    
    func initWithObject(obj:[String:AnyObject]){
        self.id = (obj["id"] as? Int)!
        self.levelNumber = (obj["level_id"] as? Int)!
        self.title = (obj["title"] as? String)!
        self.subtitle = (obj["subtitle"] as? String)!
        self.imageName = (obj["image_name_title"] as? String)!
        self.languageID = (obj["language_id"] as? Int)!
        chacheImage()
    }
    
    
    func isComplited()->Bool {
        let levels = Array(try! Realm().objects(UserBonusLevel.self))
        let userLevels = levels.filter{$0.id == self.id}
        print(userLevels)
        if userLevels.count > 0 {
            return userLevels.first?.complited ?? false
        } else  {
            return false
        }
    }
}
