//
//  GameResultViewModel.swift
//  Wordix
//
//  Created by Ігор on 11/7/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class GameResultViewModel: GameResultViewModelType {
    let realm = try? Realm()
    private var level : Level?
    private var rightClicks : Int?
    init(level:Level, rightClicks:Int) {
        self.level = level
        self.rightClicks = rightClicks
    }
    
    func successGamePercentages() -> Float {
        let percentage = (try! Realm().objects(Settings.self).first?.successGamePercentage)
        return Float(percentage ?? 100)/100.0
    }
    
    var rightWordsCount : Int {
        return self.rightClicks!//(self.level?.wordsForCurrentLevel().filter{$0.remembered == true})!.count 
    }
    
    var allWordsCount : Int {
        return self.level?.wordsForCurrentLevel().count ?? 0
    }
    
    func updateLevel(){
        self.saveProgress()
    }
    
    func viewModel() -> OpenLevelViewModelType? {
        return OpenLevelViewModel(level:self.level!)
    }
    
    func saveProgress(){
        let complitePercent = self.rightWordsCount * 100 / allWordsCount
        let successGamePercentages  = Int(self.successGamePercentages()*100)
        let isComplited  = complitePercent >= successGamePercentages
        
        let levels = Array(try! Realm().objects(UserLevel.self))
        
        if let firUser = Auth.auth().currentUser {
            let rootRef = Database.database().reference()
            let userRef = rootRef.child("users").child(firUser.uid)
            let levelRef = userRef.child("levels").child("\(self.level!.id)")
            
            var values = [String:AnyObject]()
            values["rememberedWords"] = rightWordsCount as AnyObject
            values["complitePercent"] = complitePercent as AnyObject
            values["complited"] = isComplited as AnyObject
            
            levelRef.updateChildValues(values)
        }
        
        let filteredLevels = levels.filter{$0.id==self.level?.id}
        var userLevel = UserLevel()
        if filteredLevels.count > 0 {
            userLevel = filteredLevels.first ?? UserLevel()
        } else {
            userLevel.id = self.level!.id
        }
    
        try! Realm().write {
            //userLevel.id = self.level!.id
            userLevel.rememberedWords = self.rightWordsCount
            userLevel.complitePercent = complitePercent
            userLevel.complited = isComplited
            realm?.add(userLevel, update: .all)
        }
    }
}


