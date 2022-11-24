//
//  StatisticViewModel.swift
//  Wordix
//
//  Created by Ігор on 11/8/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift

class StatisticViewModel: StatisticViewModelType {
    
    func averageWords()->Int{
        let levels = Array(try! Realm().objects(UserLevel.self))
        var average = 0
        levels.forEach{
            average = average + $0.complitePercent
        }
        if levels.count == 0 {return 0}
        return average/(levels.count )
        /*
        let levels = Array(try! Realm().objects(Level.self))
        let complitedLevels = levels.filter{$0.isComplited() == true}
        var average = 0
        complitedLevels.forEach{
            average = average + $0.complitePercent()
        }
        if complitedLevels.count == 0 {return 0}
        return average/complitedLevels.count*/
    }
    
    func mostWords()->Int {
        let levels = Array(try! Realm().objects(UserLevel.self))
        //let complitedLevels = levels?.filter{$0.complited == true}
        let sortedLevels = levels.sorted(by: {$0.complitePercent>$1.complitePercent})
        if sortedLevels.count == 0 {return 0}
        return sortedLevels.first?.complitePercent ?? 0
        /*
        let levels = Array(try! Realm().objects(Level.self))
        let complitedLevels = levels.filter{$0.isComplited() == true}
        let sortedLevels = complitedLevels.sorted(by: {$0.complitePercent()>$1.complitePercent()})
        if sortedLevels.count == 0 {return 0}
        return sortedLevels.first!.complitePercent()*/
    }
    
    func allRememberedWords()->Int{
        
        let levels = Array(try! Realm().objects(UserLevel.self))
        let words = Array(try! Realm().objects(UserWord.self))
        //let rememberedWords = words.filter{$0.remembered==true}
        var count = 0
        for level in levels {
            count = count + level.rememberedWords
        }
        return count//rememberedWords.count
        /*
        var words = try! Realm().objects(Word.self)
        let language = try! Realm().objects(Language.self).filter("current == true").first
        words = words.filter("remembered == true AND languageID == \((language?.id)!)")
        return words.count*/
    }
    
    func wordPerDate(date:Date)->Int{
        let dateStr = date.string()
        let words = Array(try! Realm().objects(UserWord.self))
        var rememberedWords = words.filter{$0.remembered==true}
        rememberedWords = rememberedWords.filter{$0.dateRemembered.contains(dateStr)}
        return rememberedWords.count 
        /*
        var words = try! Realm().objects(Word.self)
        let language = try! Realm().objects(Language.self).filter("current == true").first
        words = words.filter("remembered == true AND languageID == \((language?.id)!)")
        words = words.filter("dateRemembered contains '\(dateStr)'")
        return words.count*/
    }
    
    func wordsCountString() -> String {
        let words = self.allRememberedWords()
        switch words%10 {
        case 1 where words%100 != 11:
            return String(format: NSLocalizedString("%i word", comment: "LOC_STR"), words)
        case 2 where words%100 != 12, 3 where words%100 != 13, 4 where words%100 != 14 :
            return String(format: NSLocalizedString("%i words1", comment: "LOC_STR"), words)
        default:
            return String(format: NSLocalizedString("%i words2", comment: "LOC_STR"), words)
        }
    }
    
    
}
