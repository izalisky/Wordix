//
//  LevelTableViewCellModel.swift
//  Wordix
//
//  Created by Ігор on 10/25/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import UIKit

class LevelTableViewCellModel : LevelsTableViewCellModelType {
    
    private var level : Level?
    
    var name: String {
        return NSLocalizedString("Level", comment: "LOC_STR") + " \((level?.number)!)"
    }
    
    var words: String {
        return (level?.wordsCountString())!
    }
    
    var image : UIImage? {
        return level?.loadImageFromDocumentDirectory(fileName: level!.imageName)
    }
    
    var grayImage : UIImage? {
        return level?.loadImageFromDocumentDirectory(fileName: level!.imageName)?.grayscaled
    }
    
    var imageUrl: String {
     return level?.imageUrl() ?? ""
    }
    
    var isComplited: Bool{
        return level?.isComplited() ?? false
    }
    
    func isUnlocked() -> Bool{
        return level!.isUnlocked()
    }
    
    func levelBgImageName(forCell cell: UITableViewCell) -> UIImage {
        var name = (level?.isComplited())! == true ? "level_btn_bg_act" : "level_btn_bg"
        if cell.reuseIdentifier == "cell2" {
            name = (level?.isComplited())! == true  ? "level_btn_bg_act_2" : "level_btn_bg_2"
        }
        return UIImage(named: name) ?? UIImage()
    }
    
    func levelPlateImageName(forCell cell: UITableViewCell) -> UIImage {
        return ((level?.isComplited())! == true ? UIImage(named: "level_btn_act") : UIImage(named: "level_btn")) ?? UIImage()
    }
    
    init(level:Level) {
        self.level = level
    }
}
