//
//  Language.swift
//  Wordix
//
//  Created by Ігор on 10/29/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift

class AppLanguage: WordixObject {
    @objc dynamic var id : Int = 1
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class Language: WordixObject {
    @objc dynamic var id : Int = 0
    @objc dynamic var code : String = ""
    @objc dynamic var name : String = ""
    
    @objc dynamic var created_at : String = ""
    @objc dynamic var updated_at : String = ""
    
    
    
    func initWithObject(obj:[String:AnyObject]){
        self.id = (obj["id"] as? Int) ?? 1
        self.code = (obj["code"] as? String) ?? ""
        self.name = (obj["name"] as? String) ?? ""
        self.imageName = (obj["image_name"] as? String) ?? ""
        chacheImage()
    }
    
    func isCurrent()->Bool{
        let user = Array(try! Realm().objects(User.self)).first
        return self.id == user?.language
    }
    
    class func currentLanguage()->Language{
        let deviceLanguageCode = self.detectDeviceLanguageCode()
        let languages = Array(try! Realm().objects(Language.self))
        //let appLangauge = Array(try! Realm().objects(AppLanguage.self)).first ?? AppLanguage()
        let filteredLanguages = languages.filter{$0.code == deviceLanguageCode}
        if filteredLanguages.count > 0 {
            return filteredLanguages.first!
        }
        return Language()
    }
    
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    /*func setApplicationLanguage(){
        let deviceLanguageCode = self.detectDeviceLanguageCode()
        let languages = Array(try! Realm().objects(Language.self))
        let currLang = languages.filter{$0.code == deviceLanguageCode}.first
        try! Realm().write() {
            let lang = Array(try! Realm().objects(AppLanguage.self)).first ?? AppLanguage()
            lang.id = currLang!.id
            try! Realm().add(lang, update: Realm.UpdatePolicy.modified)
        }
    }*/
    
    class func detectDeviceLanguageCode()->String{
        if  let language = NSLocale.preferredLanguages.first {
            let dict = NSLocale.components(fromLocaleIdentifier: language)
            var languageCode = dict["kCFLocaleLanguageCodeKey"] ?? "ru"
            if languageCode == "ru" || languageCode == "ua" {
                languageCode = "ru"
            } else {
                languageCode = "en"
            }
            return languageCode
        }
        return "ru"
    }
    
}

