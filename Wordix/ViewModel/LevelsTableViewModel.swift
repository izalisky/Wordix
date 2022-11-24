//
//  LevelsTableViewModel.swift
//  Wordix
//
//  Created by Ігор on 10/25/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
import RealmSwift
import AlamofireImage
import  Firebase

class LevelsTableViewModel : LevelsTableViewModelType{
    var levels: [Level] = [Level]()
    let realm = try? Realm()
    var user : User?
    
    var delegate: LevelsTableViewController = LevelsTableViewController()
    private var selectedIndexPath : IndexPath?
    var userInfoDidLoad: (() -> Void)?
    
    func cellViewModel(forIndexPath indexPath: IndexPath) -> LevelsTableViewCellModelType? {
        let level = levels[indexPath.row]
        return LevelTableViewCellModel(level: level)
    }
    
    var numberOfRows: Int {
        return levels.count
    }
    
    func loadLevels(){
        self.levels = Array(try! Realm().objects(Level.self))
        self.delegate.tableView.reloadData()
    }
    
    func viewModelForSelectedRow() -> OpenLevelViewModelType? {
        return OpenLevelViewModel(level:(self.levels[selectedIndexPath?.row ?? 0]))
    }
       
    func selectRow(indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
    }
    
    func updateLanguageImage(btn:UIButton){
        let language = Language.currentLanguage()
        if let image = language.image {
            let scaledImage = image.resize(targetSize: CGSize(width: 32, height: 32))
            btn.setImage(scaledImage, for: .normal)
        }
    }
    
    func isSubscribed()->Bool{
        let isSubscribed = UserDefaults.standard.bool(forKey: hasActiveSubscriptionKey)
        if self.selectedIndexPath!.row > 0 && isSubscribed == false {
            return true
        } else {
            return true
        }
    }
    
    func isUnlocked()->Bool{
        let level = self.levels[self.selectedIndexPath!.row]
        return level.isUnlocked()
    }
    
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
                    self.realm?.add(model!)
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
}
