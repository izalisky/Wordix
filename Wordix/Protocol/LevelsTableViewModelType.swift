//
//  LevelsTableViewType.swift
//  Wordix
//
//  Created by Ігор on 10/25/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

protocol LevelsTableViewModelType {
    var numberOfRows : Int {get}
    var levels : [Level] {get}
    var user : User? {get}
    var delegate : LevelsTableViewController { get set }
    func cellViewModel(forIndexPath indexPath: IndexPath) -> LevelsTableViewCellModelType?
    func loadLevels()
    
    func viewModelForSelectedRow() -> OpenLevelViewModelType?
    func selectRow(indexPath:IndexPath)
    func updateLanguageImage(btn:UIButton)
    func isSubscribed()->Bool
    func isUnlocked()->Bool
    func loadUserInfo()
    var userInfoDidLoad: (() -> Void)?{get set}
}
