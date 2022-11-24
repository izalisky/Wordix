//
//  SettingsManager.swift
//  Fitness
//
//  Created by Ігор on 5/8/18.
//  Copyright © 2018 Igor Zalisky. All rights reserved.
//

import UIKit

let K_AUTH_TOKEN_KEY = "AUTH_TOKEN_KEY"
let KEY_PRO_ACTIVATED = "KEY_PRO_ACTIVATED"
let K_AUTH_EMAIL_KEY  = "K_AUTH_EMAIL_KEY"
let K_AUTH_NAME_KEY  = "K_AUTH_NAME_KEY"
let K_APPLE_USERS_KEY  = "K_APPLE_USERS_KEY"

class SettingsManager: NSObject {
    
    class func saveAuthToken(token:String?){
        if token == nil {
            UserDefaults.standard.removeObject(forKey: K_AUTH_TOKEN_KEY)
            NotificationCenter.default.post(name: Notification.Name("UserLoggedOut"), object: nil)
        } else {
            UserDefaults.standard.set(token, forKey: K_AUTH_TOKEN_KEY)
            NotificationCenter.default.post(name: Notification.Name("UserLoggedOIn"), object: nil)
        }
        UserDefaults.standard.synchronize()
    }
    
    class func saveUserEmail(email:String?){
            UserDefaults.standard.set(email, forKey: K_AUTH_EMAIL_KEY)
        UserDefaults.standard.synchronize()
    }
    
    class func saveUserName(name:String?){
            UserDefaults.standard.set(name, forKey: K_AUTH_NAME_KEY)
        UserDefaults.standard.synchronize()
    }
    
    class func saveAppleUser(forUserID userID:String, user:[String:String]){
        var users = UserDefaults.standard.object(forKey: K_APPLE_USERS_KEY) as? [[String:AnyObject]]
        if users == nil {
            users = [[String:AnyObject]]()
        }
        var nu = [String:AnyObject]()
        nu[userID] = user as AnyObject
        users?.append(nu)
        UserDefaults.standard.setValue(users, forKey: K_APPLE_USERS_KEY)
        UserDefaults.standard.synchronize()
    }
    
    class func appleUser(userID:String)->[String:String]{
        var user = [String:String]()
        let users = UserDefaults.standard.object(forKey: K_APPLE_USERS_KEY) as? [[String:AnyObject]]
        users?.forEach{
            let id = $0.keys.first ?? ""
            if id == userID {
                user = $0[id] as! [String : String]
            }
        }
        return user
    }
    
    class func authToken()->String?{
        return UserDefaults.standard.object(forKey: K_AUTH_TOKEN_KEY) as? String
    }
    
    class func authEmail()->String?{
        return UserDefaults.standard.object(forKey: K_AUTH_EMAIL_KEY) as? String
    }
    
    class func authName()->String?{
        return UserDefaults.standard.object(forKey: K_AUTH_NAME_KEY) as? String
    }
    
    class func isAuth()->Bool?{
        return SettingsManager.authToken() != nil
    }
}
