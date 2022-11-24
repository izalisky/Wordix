//
//  OpenLevelViewController.swift
//  Wordix
//
//  Created by Ігор on 10/25/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit

class OpenLevelViewController: UIViewController {
    @IBOutlet weak var nameLevelLabel : UILabel!
    @IBOutlet weak var wordsCountLabel : UILabel!
    @IBOutlet weak var levelImageView : UIImageView!
    @IBOutlet weak var learnedWordLabel : UILabel?
    @IBOutlet weak var bonusStatusLabel : UILabel?
    @IBOutlet weak var goalBonusLabel : UILabel?
    @IBOutlet weak var confeti : UIImageView?
    var viewModel : OpenLevelViewModelType?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient(colors: Constants.gradientColors1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameLevelLabel.text = viewModel?.name
        wordsCountLabel.text = viewModel?.words
        self.levelImageView.image = self.viewModel?.image
        self.learnedWordLabel?.text = viewModel?.rightWords
        self.bonusStatusLabel?.text = viewModel?.bonusForCurrentLevel().isComplited() == true ? NSLocalizedString("Completed", comment: "LOC_STR") : NSLocalizedString("Opened", comment: "LOC_STR")
        self.confeti?.isHidden = self.viewModel?.bonusForCurrentLevel().isComplited() == false
        self.goalBonusLabel?.text = self.viewModel?.goalForCurrentLevel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewModel = viewModel else { return }
        if let dvc = segue.destination as? LearnWordsController {
            dvc.viewModel = self.viewModel?.viewModel()
        } else if let dvc = segue.destination as? BonusGameViewController {
            dvc.bonusGame = viewModel.bonusForCurrentLevel()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "words" {
            return (viewModel?.wordsForCurrentLevel().count)! > 0
        } else if identifier == "bonus" {
            let bonus = viewModel?.bonusForCurrentLevel()
            return (bonus?.questions.count)! > 0
        }
        return true
    }
    
    @IBAction override func backAction() {
        self.navigationController?.popToRootViewController(animated: true)
    }

}
