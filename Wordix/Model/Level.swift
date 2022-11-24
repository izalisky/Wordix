//
//  Level.swift
//  Wordix
//
//  Created by Ігор on 10/29/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift

extension List {
    func toArray() -> [Element] {
      return compactMap {
        $0
      }
    }
 }

class Level: WordixObject {
    @objc dynamic var id : Int = 0
    @objc dynamic var number : Int = 0
    @objc dynamic var wordsCount : Int = 0
    static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    public func isComplited() -> Bool{
        //let words = self.wordsForCurrentLevel()

        let levels = Array(try! Realm().objects(UserLevel.self))
        print(levels)
        for level in levels {
            print(level)
        }
        
        let words = Array(try! Realm().objects(UserWord.self))
        for word in words {
            print(word)
        }
        
        let userLevels = levels.filter{$0.id == self.number}
        print(userLevels)
        if userLevels.count > 0 {
            return userLevels.first?.complited ?? false
        } else  {
            return false
        }
        /*if words.count > 0 {
        let rightWords = words.filter{$0.isRemembered() == true}
        let per = rightWords.count * 100 / words.count
        return per >= 40
        } else { return false}*/
    }
    
    public func isUnlocked() -> Bool{
        var prevLevel : Level?
        if self.number > 1 {
            let levels = try! Realm().objects(Level.self)
            prevLevel = levels.filter{$0.number == self.number-1}.first
        }
        return prevLevel == nil || prevLevel?.isComplited() == true
    }
    
     func wordsForCurrentLevel() -> [Word] {
        var words = try! Realm().objects(Word.self)
        let language = Language.currentLanguage()
        words = words.filter("levelNumber == \(self.id) AND languageID == \((language.id))")
           return Array(words)
       }
    
    func wordsCountString() -> String {
        let words = self.wordsForCurrentLevel().count
        switch words%10 {
        case 1 where words%100 != 11:
            return String(format: NSLocalizedString("%i word", comment: "LOC_STR"), words)
        case 2 where words%100 != 12, 3 where words%100 != 13, 4 where words%100 != 14 :
            return String(format: NSLocalizedString("%i words1", comment: "LOC_STR"), words)
        default:
            return String(format: NSLocalizedString("%i words2", comment: "LOC_STR"), words)
        }
    }
    
   
    
    func initWithObject(obj:[String:AnyObject]){
        self.id = (obj["id"] as? Int)!
        self.number = (obj["number"] as? Int) ?? 0
        self.imageName = (obj["image_name"] as? String) ?? ""
        chacheImage()
    }
    
    
    func complitePercent() -> Int {
        let levels = Array(try! Realm().objects(UserLevel.self))
        let filtredLevels = levels.filter{$0.id == self.id}
        if filtredLevels.count > 0 {
            let userLevel = filtredLevels.first
            return userLevel?.complitePercent ?? 0
        }
        return 0
    }
    
    func rememberedWordsCount() -> Int {
        let levels = Array(try! Realm().objects(UserLevel.self))
        let filtredLevels = levels.filter{$0.id == self.id}
        if filtredLevels.count > 0 {
            let userLevel = filtredLevels.first
            return userLevel?.rememberedWords ?? 0
        }
        return 0
    }
    
    
    
   
    
    
}
