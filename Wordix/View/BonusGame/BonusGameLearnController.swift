//
//  BonusGameLearnController.swift
//  Wordix
//
//  Created by Ігор on 11/4/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
import AlamofireImage

class BonusGameLearnController: UIViewController {
    @IBOutlet weak var circleView: UIImageView!
    var questions : [Questions]?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerBtn: UIButton!
    var index = 0
    var bonus : Bonus?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient(colors: Constants.gradientColorsBonus)
        circleView.layer.cornerRadius = circleView.frame.size.height/2.0
        updateView()
        self.answerBtn.titleLabel?.numberOfLines = 4
        self.answerBtn.titleLabel?.textAlignment = .center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleView.layer.cornerRadius = circleView.frame.size.height/2.0
        self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2.0
    }
    
    
    func updateView(){
        guard questions?.count != 0 else {return}
        let question = questions?[index]
        titleLabel.text = question?.question
        self.subtitleLabel.text = bonus?.title
        self.imageView.image = question?.image
        self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2.0
        answerBtn.setTitle(question?.rightAnswer, for: .normal)
    }
    
    @IBAction func continueAction(){
        if index < questions!.count - 1 {
        index = index + 1
            updateView()
        } else {
            let controller = self.storyboard?.instantiateViewController(identifier: "quiz") as? BonusGameQuizController
            controller?.questions = self.questions
            controller?.bonus = self.bonus
            self.navigationController?.pushViewController(controller!, animated: true)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
