//
//  LevelWordsViewModel.swift
//  Wordix
//
//  Created by Ігор on 10/28/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift

class LearnWordsViewModel: LearnWordsViewModelType {
    private var level : Level?
    var cacher = ImageCacher()
    
    var maxTime : Int {
        let timeForRemembering = (try! Realm().objects(Settings.self).first?.timeForRemembering)
        return timeForRemembering ?? 60
    }
    
    init(level:Level) {
        self.level = level
    }
    
    
    func viewModel() -> GameProcessViewModel? {
        return GameProcessViewModel(level:self.level!)
    }
    
    func words() -> [Word] {
        return (self.level?.wordsForCurrentLevel())!
    }
    
    private func cacheLotImages() {
        for word in words() {
            cacher.cachingImage(url: word.imageUrl())
        }
        //
    }
}
