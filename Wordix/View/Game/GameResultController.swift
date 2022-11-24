//
//  GameResultController.swift
//  Wordix
//
//  Created by Ігор on 11/6/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit

class GameResultController: UIViewController {
    
    @IBOutlet weak var wordsNumberLabel : UILabel!
    @IBOutlet weak var wordsCountLabel : UILabel!
    @IBOutlet weak var resultLabel : UILabel!
    @IBOutlet weak var noteLabel : UILabel!
    @IBOutlet weak var confetiView : UIImageView!
    @IBOutlet weak var buttonContinue: UIButton!
    var viewModel : GameResultViewModelType?
    var percentage : Float = 1.0
    var isComplited = false

    override func viewDidLoad() {
        super.viewDidLoad()
        percentage = self.viewModel!.successGamePercentages()
        isComplited = Float((self.viewModel?.rightWordsCount)!)/Float((self.viewModel?.allWordsCount)!) >= percentage
        self.view.addGradient(colors: Constants.gradientColors3)
        self.wordsNumberLabel.text = "\(self.viewModel?.rightWordsCount ?? 0)"
        self.wordsCountLabel.text = "\(self.viewModel?.allWordsCount ?? 0)"
        let cf = Float((self.viewModel?.allWordsCount)!) * percentage
        let c = Int(cf) + (cf-Float(Int(cf)) > 0.0 ? 1 : 0)
        resultLabel.text = isComplited ? NSLocalizedString("Cool result", comment: "") : NSLocalizedString("Your result", comment: "")
        noteLabel.text = isComplited ? NSLocalizedString("Congratulations, the bonus\nlevel is open!", comment: "") : String(format: NSLocalizedString("Try to memorize %i words or more to unlock the bonus level", comment: ""), c)
        buttonContinue.setTitle(NSLocalizedString("continue", comment: "").capitalized, for: .normal)
        self.confetiView.isHidden = Float((self.viewModel?.rightWordsCount)!)/Float((self.viewModel?.allWordsCount)!) < percentage
        self.viewModel?.updateLevel()
    }
    

    @IBAction func continueAction(){
        if self.isComplited == true {
            let controller = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "open_complited_level") as? OpenLevelViewController
            controller?.viewModel = self.viewModel?.viewModel()
            self.navigationController?.pushViewController(controller!, animated: true)
        } else {
            self.navigationController?.popToViewController(self.popController(), animated: true)
        }
    }
        
        func popController()->UIViewController{
            let controller = self.navigationController?.viewControllers.filter{$0 is OpenLevelViewController}.first
            return controller!
        }
}
