//
//  OnboardingViewModel.swift
//  Wordix
//
//  Created by Ігор on 11/3/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class OnboardingViewModel : OnboardingViewModelType{
    let realm = try? Realm()
    var loadingContentDidFinish: (() -> Void)?
    var loadingContentChangeProgress: ((Int) -> Void)?
    var maxProgress = 0
    var ref: DatabaseReference!
    
    func loadContentIfNeed() {
        /*let levels = realm?.objects(Level.self)
        if levels?.count == 0 {
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(self.progressDidChange),
             name: NSNotification.Name(rawValue: "K_DOWNLOADING_CONTENT_PROGRESS_DID_CHANGE"),
             object: nil)
            self.runRequest(type: .Level)
        } else {
            DispatchQueue.main.async { self.loadingContentDidFinish?() }
        }*/
        let contentDidLoaded = UserDefaults.standard.bool(forKey: "K_CONTENT_DID_LOADED")
        if contentDidLoaded == false {
            UserDefaults.standard.setValue(true, forKey: "K_CONTENT_DID_LOADED")
            UserDefaults.standard.synchronize()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.progressDidChange),
            name: NSNotification.Name(rawValue: "K_DOWNLOADING_CONTENT_PROGRESS_DID_CHANGE"),
            object: nil)
        self.runRequest(type: .Level)
        } else {
            DispatchQueue.main.async { self.loadingContentDidFinish?() }
        }
    }
    
    private func runRequest(type:RequestType){
        self.loadDatabaseFromFirebase()
        /*let api = ApiRequests()
        api.request(type) { (obj, err) in
            self.parseResponse(obj: obj, err: err, type: type)
        }
        self.runNextRequestIfNeed(type: type)*/
    }
    
    private func parseResponse(obj:AnyObject?, err:Error?, type:RequestType){
        if let data = obj as? [String : AnyObject] {
                let json = data["data"]
                if json is [[String:AnyObject]] {
                    let array = json as? [[String:AnyObject]]
                    guard let items = array else { return }
                    for item in items {
                        let model = createModel(item: item, type: type)
                        if model != nil {
                            try? self.realm?.write() {
                                self.realm?.add(model!)
                            }
                        }
                    }
                    //self.deleteIfNeed(type: type, items: items)
                } else if json is [String:AnyObject] {
                    let item = json as? [String:AnyObject]
                    let model = createModel(item: item!, type: type)
                    if model != nil {
                        try? self.realm?.write() {
                        self.realm?.add(model!)
                        }
                    }
                }
        }
    }
    
    func deleteIfNeed(type:RequestType, items:[[String:AnyObject]]){
        switch type {
        case .Level:
            let levels = Array(try! Realm().objects(Level.self))
            var itemsToDelete = [Level]()
            for level in levels {
                var needDelete = true
                for item in items {
                    let model = Level()
                    model.initWithObject(obj: item)
                    if level.id == model.id && level.number == model.number {
                        needDelete = false
                    }
                }
                if needDelete {
                    itemsToDelete.append(level)
                }
            }
            try? self.realm?.write() {
                self.realm?.delete(itemsToDelete)
            }
        case .Word:
            let words = Array(try! Realm().objects(Word.self))
            var itemsToDelete = [Word]()
            for word in words {
                var needDelete = true
                for item in items {
                    let model = Word()
                    model.initWithObject(obj: item)
                    if word.id == model.id && word.name == model.name {
                        needDelete = false
                    }
                }
                if needDelete {
                    itemsToDelete.append(word)
                }
            }
            try? self.realm?.write() {
                self.realm?.delete(itemsToDelete)
            }
        case .Language:
            let languages = Array(try! Realm().objects(Language.self))
            var itemsToDelete = [Language]()
            for language in languages {
                var needDelete = true
                for item in items {
                    let model = Language()
                    model.initWithObject(obj: item)
                    if language.id == model.id && language.name == model.name {
                        needDelete = false
                    }
                }
                if needDelete {
                    itemsToDelete.append(language)
                }
            }
            try? self.realm?.write() {
                self.realm?.delete(itemsToDelete)
            }
        case .Bonus:
            let bonuses = Array(try! Realm().objects(Bonus.self))
            var itemsToDelete = [Bonus]()
            for bonus in bonuses {
                var needDelete = true
                for item in items {
                    let model = Bonus()
                    model.initWithObject(obj: item)
                    if bonus.id == model.id && bonus.title == model.title {
                        needDelete = false
                    }
                }
                if needDelete {
                    itemsToDelete.append(bonus)
                }
            }
            try? self.realm?.write() {
                self.realm?.delete(itemsToDelete)
            }
        default:
            break
        }
    }
    
    private func createModel(item:[String:AnyObject], type:RequestType)->WordixObject?{
        switch type {
        case .Level:
            let model = Level()
            model.initWithObject(obj: item)
            if (realm?.object(ofType: Level.self, forPrimaryKey: model.id)) != nil {
                return nil
            } else {
                return model
            }
        case .Word:
            let model = Word()
            model.initWithObject(obj: item)
            if (realm?.object(ofType: Word.self, forPrimaryKey: model.id)) != nil {
                return nil
            } else {
                return model
            }
        case .Language:
            let model = Language()
            model.initWithObject(obj: item)
            if (realm?.object(ofType: Language.self, forPrimaryKey: model.id)) != nil {
                return nil
            } else {
                return model
            }
        case .Bonus:
            let model = Bonus()
            model.initWithObject(obj: item)
            if (realm?.object(ofType: Bonus.self, forPrimaryKey: model.id)) != nil {
                return nil
            } else {
                return model
            }
        case .Question:
            let model = Questions()
            model.initWithObject(obj: item)
            if (realm?.object(ofType: Questions.self, forPrimaryKey: model.id)) != nil {
                return nil
            } else {
                return model
            }
        case .Settings:
            let model = Settings()
            model.initWithObject(obj: item)
            return model
        case .Users:
            let model = User()
            model.initWithObject(obj: item)
            return model
        }
    }
        
    private func runNextRequestIfNeed(type:RequestType){
        switch type {
        case .Level:
            self.runRequest(type: .Word)
        case .Word:
            self.runRequest(type: .Language)
        case .Language:
            self.runRequest(type: .Bonus)
        case .Bonus:
            self.runRequest(type: .Question)
        case .Question:
            self.runRequest(type: .Settings)
        case .Settings:
            break
        case .Users:
            break
            //DispatchQueue.main.async { self.loadingContentDidFinish?() }
            //self.loadingContentDidFinish?()
        }
    }
    
    func urlsForLevels()->[String]{
        var array = [String]()
        let levels = Array(try! Realm().objects(Level.self))
        for level in levels {
            let url = level.imageUrl()
            array.append(url)
        }
        return array
    }
    
    @objc func progressDidChange(notification: NSNotification){
        let progress = notification.userInfo?["progress"] as! Int
        print("\(progress)")
        if progress > maxProgress {
            maxProgress = progress
        }
        loadingContentChangeProgress?(maxProgress)
        if maxProgress == 100 {
            DispatchQueue.main.async { self.loadingContentDidFinish?() }
        }
    }
    
    func clearRealm(){
        let ud = UserDefaults.standard
        ud.removeObject(forKey: "K_END_DOWNLOADED")
        ud.removeObject(forKey: "K_START_DOWNLOADED")
        ud.synchronize()
        if let levels = realm?.objects(Level.self) {
            try? self.realm?.write() {
                self.realm?.delete(levels)
            }
        }
        if let words = realm?.objects(Word.self) {
            try? self.realm?.write() {
                self.realm?.delete(words)
            }
        }
        if let languages = realm?.objects(Language.self) {
            try? self.realm?.write() {
                self.realm?.delete(languages)
            }
        }
        if let bonus = realm?.objects(Bonus.self) {
            try? self.realm?.write() {
                self.realm?.delete(bonus)
            }
        }
        if let questions = realm?.objects(Questions.self) {
            try? self.realm?.write() {
                self.realm?.delete(questions)
            }
        }
        if let settings = realm?.objects(Settings.self) {
            try? self.realm?.write() {
                self.realm?.delete(settings)
            }
        }
    }
    
    
    func loadDatabaseFromFirebase(){
        ref = Database.database().reference()
        ref.observe(.value) { (snapshot) in
            self.ref.removeAllObservers()
            self.clearRealm()
            for child in snapshot.children{
                let key = (child as? DataSnapshot)?.key
                if let json = (child as? DataSnapshot)?.value as? NSArray {
                    var type : RequestType?
                    switch key {
                    case "bonus_games":
                        type = .Bonus
                    case "languages":
                        type = .Language
                        for item in json {
                            if let dict = item as? [String : AnyObject] {
                                let model = self.createModel(item: dict, type: type!) as? Language
                                if model != nil {
                                try? self.realm?.write() {
                                    self.realm?.add(model!)
                                }
                                }
                            }
                        }
                    case "levels":
                        type = .Level
                    case "questions":
                        type = .Question
                    case "words":
                        type = .Word
                    case "users":
                        type = .Users
                    default:
                        break
                    }
                    
                    if type != .Language {
                    for item in json {
                        if let dict = item as? [String : AnyObject] {
                            let model = self.createModel(item: dict, type: type!)
                            if model != nil {
                            try? self.realm?.write() {
                                self.realm?.add(model!)
                            }
                            }
                        }
                    }
                    }
                } else if let json = (child as? DataSnapshot)?.value as? [String:AnyObject] {
                    if key == "settings" {
                        let model = self.createModel(item: json, type: .Settings) as? Settings
                    if model != nil {
                        try? self.realm?.write() {
                        self.realm?.add(model!)
                        }
                    }
                    }
                }
            }
        }
    }
}
