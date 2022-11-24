//
//  Level.swift
//  Wordix
//
//  Created by Ігор on 10/29/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift

class User: WordixObject {
    @objc dynamic var uid : String = ""
    @objc dynamic var email : String = ""
    @objc dynamic var language : Int = 1
    dynamic var levels : List<UserLevel> = List<UserLevel>()
    dynamic var words : List<UserWord> = List<UserWord>()
    //dynamic var questions : List<UserData> = List<UserData>()
    
    override class func primaryKey() -> String? {
        return "uid"
    }
    
    func initWithObject(obj:[String:AnyObject]){
        self.uid = (obj["uid"] as? String)!
        self.email = (obj["email"] as? String) ?? ""
        
        if let wordsDict = obj["words"] as? [String:AnyObject] {
            let keys = wordsDict.keys
            for key in keys {
                var word = wordsDict[key] as? [String:AnyObject]
                word?["id"] = Int(key) as AnyObject
                if key != "0"{
                let userWord = UserWord()
                userWord.initWithObject(obj: word!)
                words.append(userWord)
                }
            }
        }
        
        if let levelsDict = obj["levels"] as? [String:AnyObject] {
            let keys = levelsDict.keys
            for key in keys {
                var level = levelsDict[key] as? [String:AnyObject]
                level?["id"] = Int(key) as AnyObject
                let userLevel = UserLevel()
                userLevel.initWithObject(obj: level!)
                levels.append(userLevel)
            }
        }
        
        if let levelsArray = obj["levels"] as? NSArray{
            var sa = [[String:AnyObject]]()
            for item in levelsArray {
                if let dict = item as? [String:AnyObject] {
                sa.append(dict)
                }
            }
            var index = 1
            for level in sa {
                let userLevel = UserLevel()
                userLevel.initWithObject(obj: level)
                userLevel.id = index
                levels.append(userLevel)
                index = index + 1
            }
        }
    }
}

class UserLevel: WordixObject {
    @objc dynamic var id : Int = 0
    @objc dynamic var complitePercent : Int = 0
    @objc dynamic var rememberedWords : Int = 0
    @objc dynamic var complited : Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func initWithObject(obj:[String:AnyObject]){
        self.id = (obj["id"] as? Int) ?? 0
        self.complitePercent = (obj["complitePercent"] as? Int) ?? 0
        self.rememberedWords = (obj["rememberedWords"] as? Int) ?? 0
        self.complited = (obj["complited"] as? Bool) ?? false
    }
}

class UserBonusLevel: WordixObject {
    @objc dynamic var id : Int = 0
    @objc dynamic var level_id : Int = 0
    @objc dynamic var complitePercent : Int = 0
    @objc dynamic var complited : Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func initWithObject(obj:[String:AnyObject]){
        self.id = (obj["id"] as? Int) ?? 0
        self.complitePercent = (obj["complitePercent"] as? Int) ?? 0
        self.level_id = (obj["level_id"] as? Int) ?? 0
        self.complited = (obj["bonus_complited"] as? Bool) ?? false
    }
}

class UserWord: WordixObject {
    @objc dynamic var id : Int = 0
    @objc dynamic var dateRemembered : String = ""
    @objc dynamic var learned : Bool = false
    @objc dynamic var remembered : Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func initWithObject(obj:[String:AnyObject]){
        self.id = (obj["id"] as? Int) ?? 0
        self.dateRemembered = (obj["dateRemembered"] as? String) ?? ""
        self.learned = (obj["learned"] as? Bool) ?? false
        self.remembered = (obj["remembered"] as? Bool) ?? false
    }
}
