//
//  File.swift
//  Wordix
//
//  Created by Ігор on 11/3/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
import AlamofireImage

class BonusGameViewController: UIViewController {
    @IBOutlet weak var circleView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var bonusGame: Bonus?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient(colors: Constants.gradientColorsBonus)
        circleView.layer.cornerRadius = circleView.frame.size.height/2.0
        self.titleLabel.text = bonusGame?.title
        self.subtitleLabel.text = bonusGame?.subtitle
        self.imageView.image = bonusGame?.image
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleView.layer.cornerRadius = circleView.frame.size.height/2.0
        self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2.0
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as? BonusGameLearnController
        dvc?.questions = Array(bonusGame!.questions)
        dvc?.bonus = bonusGame
    }
    
}
