//
//  AuthViewModel.swift
//  Wordix
//
//  Created by Ihor Zaliskyj on 02.03.2021.
//  Copyright © 2021 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireImage
import  Firebase

class AuthViewModel : AuthViewModelType{
    var user : User?
    var userInfoDidLoad: (() -> Void)?
    let realm = try? Realm()
    
    
    func loadUserInfo(){
        let user = Array(try! Realm().objects(User.self)).first
        if user == nil {
        if let user = Auth.auth().currentUser {
            let rootRef = Database.database().reference()
            let userRef = rootRef.child("users").child(user.uid)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                self.parseUser(snapshot: snapshot)
            })
        }
        } else {
            self.user = user
            self.userInfoDidLoad?()
        }
    }
    
    func parseUser(snapshot:DataSnapshot)  {
        if let json = snapshot.value as? [String : AnyObject] {
            let model = self.createModel(item: json)
            if model != nil {
                try? self.realm?.write() {
                    self.realm?.add(model!,update: .all)
                }
            }
            
            if let wordsDict = json["words"] as? [String:AnyObject] {
                let keys = wordsDict.keys
                for key in keys {
                    var word = wordsDict[key] as? [String:AnyObject]
                    word?["id"] = Int(key) as AnyObject
                    if key != "0"{
                    let userWord = UserWord()
                    userWord.initWithObject(obj: word!)
                        try? self.realm?.write() {
                            self.realm?.add(userWord,update: .all)
                        }
                    }
                }
            }
            
            if let bonusDict = json["bonus"] as? [String:AnyObject] {
                let keys = bonusDict.keys
                for key in keys {
                    var word = bonusDict[key] as? [String:AnyObject]
                    word?["id"] = Int(key) as AnyObject
                    if key != "0"{
                    let userBonus = UserBonusLevel()
                        userBonus.initWithObject(obj: word!)
                        try? self.realm?.write() {
                            self.realm?.add(userBonus,update: .all)
                        }
                    }
                }
            }
            
            if let bonusArray = json["bonus"] as? NSArray{
                var sa = [[String:AnyObject]]()
                for item in bonusArray {
                    if let dict = item as? [String:AnyObject] {
                    sa.append(dict)
                    }
                }
                var index = 1
                for level in sa {
                    let userBonus = UserBonusLevel()
                    userBonus.initWithObject(obj: level)
                    userBonus.id = index
                    try? self.realm?.write() {
                        self.realm?.add(userBonus,update: .all)
                    }
                    index = index + 1
                }
            }
            
            if let levelsDict = json["levels"] as? [String:AnyObject] {
                let keys = levelsDict.keys
                for key in keys {
                    var level = levelsDict[key] as? [String:AnyObject]
                    level?["id"] = Int(key) as AnyObject
                    let userLevel = UserLevel()
                    userLevel.initWithObject(obj: level!)
                    try? self.realm?.write() {
                        self.realm?.add(userLevel,update: .all)
                    }
                }
            }
            
            if let levelsArray = json["levels"] as? NSArray{
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
                    try? self.realm?.write() {
                        self.realm?.add(userLevel,update: .all)
                    }
                    index = index + 1
                }
            }
            
            
            self.user = model
            self.userInfoDidLoad?()
        }
    }
    
    func createModel(item:[String:AnyObject])->User?{
        let model = User()
        model.initWithObject(obj: item)
        if (realm?.object(ofType: User.self, forPrimaryKey: model.uid)) != nil {
            return nil
        } else {
            return model
        }
    }
    
    func createLevel(item:[String:AnyObject])->UserLevel?{
        let model = UserLevel()
        model.initWithObject(obj: item)
        return model
    }
    
    func createWord(item:[String:AnyObject])->UserWord?{
        let model = UserWord()
        model.initWithObject(obj: item)
        return model
    }
}
