//
//  Settings.swift
//  Wordix
//
//  Created by Ігор on 11/9/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift

class Settings : WordixObject {
    @objc dynamic var successGamePercentage : Int = 40
    @objc dynamic var timeForRemembering : Int = 0
    
    
    func initWithObject(obj:[String:AnyObject]) {
        self.successGamePercentage = (obj["successGamePercentage"] as? Int)!
        self.timeForRemembering = (obj["timeForRemembering"] as? Int)!
    }
}
