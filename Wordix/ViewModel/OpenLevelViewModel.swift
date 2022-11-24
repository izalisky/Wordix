//
//  OpenLevelViewModel.swift
//  Wordix
//
//  Created by Ігор on 10/27/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Firebase

extension Results {
    func toArray() -> [Element] {
      return compactMap {
        $0
      }
    }
 }

class OpenLevelViewModel : OpenLevelViewModelType {
    let realm = try? Realm()
     private var level : Level?
       
       var name: String {
           return NSLocalizedString("Level", comment: "LOC_STR") + " \((level?.number)!)"
       }
       
       var words: String {
        return (level?.wordsCountString())!
       }
    
    var rightWords: String {
        let complitedCount = level?.rememberedWordsCount()
        let allCount = level?.wordsForCurrentLevel().count ?? 0
        return "\(complitedCount!) / \(allCount) " + NSLocalizedString("words2", comment: "LOC_STR")
    }
    
    var image: UIImage? {
        return self.level?.loadImageFromDocumentDirectory(fileName: self.level?.imageName ?? "")
    }
    
    func viewModel() -> LearnWordsViewModel? {
        return LearnWordsViewModel(level:self.level!)
    }
    
       
       var imageUrl: String {
        return level?.imageUrl() ?? ""
       }
       
       var isComplited: Bool{
           return level?.isComplited() ?? false
       }
       
       
       init(level:Level) {
           self.level = level
       }
    
    func wordsForCurrentLevel() -> [Word] {
         var words = try! Realm().objects(Word.self)
        let language = Language.currentLanguage()
        words = words.filter("levelNumber == \((self.level?.number)!) AND languageID == \((language.id))")
        return Array(words)
    }
    
    func bonusForCurrentLevel() -> Bonus {
        var bonus_levels = try! Realm().objects(Bonus.self)
        let language = Language.currentLanguage()
        bonus_levels = bonus_levels.filter("levelNumber == \((self.level?.number)!) AND languageID == \((language.id))")
        if let bonus = bonus_levels.first  {
            bonus.questions = self.questionForBonus(bonus: bonus)
            return bonus
        }
        return Bonus()
    }
    
    func questionForBonus(bonus:Bonus) -> List<Questions> {
        var questions = try! Realm().objects(Questions.self)
        questions = questions.filter("bonus_game_id == \(bonus.id)")
        let list = List<Questions>()
        questions.forEach{
            list.append($0)
        }
        return list
    }
    
    func goalForCurrentLevel() -> String {
        let percentage = (try! Realm().objects(Settings.self).first?.successGamePercentage)
        let p = Float(percentage ?? 100)/100.0
        let w = self.wordsForCurrentLevel().count
        var rw = Int(Float(w)*p)
        if Float(w)*p > Float(rw) {
            rw = rw + 1
        }
        return String(format: NSLocalizedString("Guess %d/%d words", comment: "LOC_STR"), rw,w)
    }
    
}
