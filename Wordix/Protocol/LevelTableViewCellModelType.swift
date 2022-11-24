//
//  LevelTableViewCellType.swift
//  Wordix
//
//  Created by Ігор on 10/25/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import UIKit

protocol LevelsTableViewCellModelType : class {
    var name : String { get }
    var words : String { get }
    var imageUrl : String { get }
    var isComplited : Bool { get }
    
    var image : UIImage? { get }
    
    var grayImage : UIImage? { get }
    
    func levelBgImageName(forCell cell: UITableViewCell) -> UIImage
    func levelPlateImageName(forCell cell: UITableViewCell) -> UIImage
    func isUnlocked() -> Bool
}
