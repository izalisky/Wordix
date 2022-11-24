//
//  Word.swift
//  Wordix
//
//  Created by Ігор on 10/29/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift

class Word: WordixObject {
    @objc dynamic var id : Int = 0
    @objc dynamic var levelNumber : Int = 0
    @objc dynamic var languageID : Int = 0
    @objc dynamic var name : String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func initWithObject(obj:[String:AnyObject]){
        self.id = (obj["id"] as? Int)!
        self.levelNumber = (obj["level_id"] as? Int) ?? 0
        self.languageID = (obj["language_id"] as? Int) ?? 0
        self.name = (obj["name"] as? String) ?? ""
        self.imageName = (obj["image_name"] as? String) ?? ""
        chacheImage()
    }
    
    func isLearned() -> Bool {
        let words = Array(try! Realm().objects(UserWord.self))
        let filtredWords = words.filter{$0.id == self.id}
        if filtredWords.count > 0 {
            let userWord = filtredWords.first
            return userWord?.learned ?? false
        }
        return false
    }
    
    
    func isRemembered() -> Bool {
        let words = Array(try! Realm().objects(UserWord.self))
        let filtredWords = words.filter{$0.id == self.id}
        if filtredWords.count > 0 {
            let userWord = filtredWords.first
            return userWord?.remembered ?? false
        }
        return false
    }
}
