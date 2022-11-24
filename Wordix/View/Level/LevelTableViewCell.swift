//
//  LevelTableViewCell.swift
//  Wordix
//
//  Created by Ігор on 10/25/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class LevelTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLevelLabel : UILabel!
    @IBOutlet weak var wordsCountLabel : UILabel!
    @IBOutlet weak var levelImageView : UIImageView!
    @IBOutlet weak var overlay : UIImageView!
    
    @IBOutlet weak var levelBgImage : UIImageView!
    @IBOutlet weak var levelPlateImage : UIImageView!
    @IBOutlet weak var complitedIco : UIImageView?
    var cacher = ImageCacher()
    
    weak var viewModel : LevelsTableViewCellModelType? {
        willSet(viewModel) {
            guard let viewModel = viewModel else {return}
            nameLevelLabel.text = viewModel.name
            wordsCountLabel.text = viewModel.words
            
            complitedIco?.isHidden = !viewModel.isComplited
            levelPlateImage.image = viewModel.levelPlateImageName(forCell: self)
            nameLevelLabel.textColor = viewModel.isComplited == true ? .white : .black
            
            levelBgImage.image = viewModel.levelBgImageName(forCell: self)
            
            if let image = viewModel.image  {
            self.levelImageView.image = image
            self.overlay.image = image.withRenderingMode(.alwaysTemplate)
            self.overlay.tintColor = .black
            }
            
            
            self.levelPlateImage.alpha = viewModel.isUnlocked() == true ? 1.0 : 0.75
            self.nameLevelLabel.alpha = viewModel.isUnlocked() == true ? 1.0 : 0.75
            self.wordsCountLabel.alpha = viewModel.isUnlocked() == true ? 1.0 : 0.75
            self.levelImageView.alpha = viewModel.isUnlocked() == true ? 1.0 : 0.75
            self.overlay.alpha = viewModel.isUnlocked() == true ? 0.0 : 0.5
        }
    }
    
    override func awakeFromNib() {
    }
    
    
     func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
       /* if identifier == "open_new_level_segue" || identifier == "open_complited_level_segue" {
            let canOpenLevel = self.viewModel?.canOpenLevel()
            if canOpenLevel == false {
                self.showSubscribeController()
            }
            return canOpenLevel!
        } else {
            return true
        }*/
        return true
    }

}
