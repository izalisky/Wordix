//
//  GameProcessModel.swift
//  Wordix
//
//  Created by Ігор on 11/6/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class GameProcessViewModel : GameProcessViewModelType{
    var clicks = 0
    var rightClicks = 0
    
    private var level : Level?
    
     init(level:Level) {
         self.level = level
     }
    
    func clicksLeftCount()->String{
        let count = self.rightWordsCount() - clicks
        switch count%10 {
        case 1 where count%100 != 11:
            return String(format: NSLocalizedString("%i click left", comment: "LOC_STR"), count)
        case 2 where count%100 != 12, 3 where count%100 != 13, 4 where count%100 != 14 :
            return String(format: NSLocalizedString("%i clicks left1", comment: "LOC_STR"), count)
        default:
            return String(format: NSLocalizedString("%i clicks left2", comment: "LOC_STR"), count)
        }
    }
    
    func clicksLeft()->Int{
        let count = self.rightWordsCount() - clicks
        return count
    }
    
    func rightClicksCount()->Int{
        return rightClicks
    }
    
    func didClick(word:Word){
        if self.isRightWord(word: word) == true {
            self.rightClicks = rightClicks + 1
            self.updateWord(word: word)
        }
        clicks = clicks + 1
    }
    
    func updateWord(word:Word){
        
        if let user = Auth.auth().currentUser {
            let rootRef = Database.database().reference()
            let userRef = rootRef.child("users").child(user.uid)
            let levelRef = userRef.child("words").child("\(word.id)")
            levelRef.updateChildValues(["remembered":true,"dateRemembered":Date().string()])
            //levelRef.setValue(["remembered":true,"dateRemembered":Date().string()])
        }

        let words = Array(try! Realm().objects(UserWord.self))
        let fwords = words.filter{$0.id==word.id}
        if fwords.count > 0 {
            try! Realm().write {
                let userWord = fwords.first
                userWord?.remembered = true
                userWord?.dateRemembered = Date().string()
                try! Realm().add(userWord!, update: Realm.UpdatePolicy.modified)
            }
        } else {
            try! Realm().write {
            let userWord = UserWord()
            userWord.id = word.id
            userWord.remembered = true
            userWord.dateRemembered = Date().string()
            try! Realm().add(userWord)
            }
        }
    }
    
    func isRightWord(word:Word)->Bool{
        return word.levelNumber == self.level?.number
    }
    
    func generateFakeWords()->[Word]{
        var words = try! Realm().objects(Word.self)
        let language = Language.currentLanguage()
        words = words.filter("levelNumber != \(level!.number) AND languageID == \((language.id))")
        let array = Array(words).shuffled()
        var fakeWords = [Word]()
        for fw in array {
            var canAdd = true
            for cw in fakeWords {
                if fw.name == cw.name {
                    canAdd = false
                    break
                }
            }
            if canAdd {
                fakeWords.append(fw)
            }
        }
        let rightWords = self.level?.wordsForCurrentLevel()
        
        let filtredFakeWords = fakeWords.filter { fw in
            return !(rightWords?.contains(where: { rw in
                return rw.name == fw.name
            }))!
        }
        let max = filtredFakeWords.count > self.level!.wordsForCurrentLevel().count ? self.level!.wordsForCurrentLevel().count : filtredFakeWords.count
        let na = filtredFakeWords[0..<max]
        return Array(na)
    }
    
    func rightWordsCount()->Int{
        return self.level?.wordsForCurrentLevel().count ?? 0
    }
    
    func words() -> [Word]{
        let fakeWords = self.generateFakeWords()
        let words = self.level!.wordsForCurrentLevel()
        let tags = fakeWords + words
        return tags.shuffled()
    }
    
    func resultViewModel() -> GameResultViewModelType? {
        return GameResultViewModel(level:self.level!, rightClicks: rightClicks)
    }
}
