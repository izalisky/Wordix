//
//  BonusGameQuizController.swift
//  Wordix
//
//  Created by Ігор on 11/4/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class BonusGameQuizController: UIViewController {
    @IBOutlet weak var circleView: UIImageView!
    var questions : [Questions]?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerBtn: UIButton!
    @IBOutlet weak var answerBtn1: UIButton!
    @IBOutlet weak var answerBtn2: UIButton!
    @IBOutlet weak var answerBtn3: UIButton!
    var buttons = [UIButton]()
    var index = 0
    var rightAnswers = 0
    var answers = [String]()
    var bonus : Bonus?
    let realm = try? Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttons = [answerBtn, answerBtn1, answerBtn2, answerBtn3]
        self.view.addGradient(colors: Constants.gradientColorsBonus)
        circleView.layer.cornerRadius = circleView.frame.size.height/2.0
        updateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleView.layer.cornerRadius = circleView.frame.size.height/2.0
        self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2.0
    }
    
    @objc func updateView(){
        let question = questions?[index]
        titleLabel.text = question?.question
        self.subtitleLabel.text = bonus?.title
        self.answers = Array(question!.fakeAnswers)
        answers.append(question!.rightAnswer)
        self.imageView.image = question?.image
        self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2.0
        answerBtn.setTitle(question?.rightAnswer, for: .normal)
        self.buttons.forEach{
            $0.titleLabel?.numberOfLines = 4
            $0.titleLabel?.textAlignment = .center
            $0.setBackgroundImage(UIImage(named: "button_bonus"), for: .normal);
            $0.isUserInteractionEnabled = true
            $0.setTitleColor(.black, for: .normal)
            $0.setTitle(randomAnswer(question: question!), for: .normal)
        }
    }
    
    func randomAnswer(question:Questions)->String{
        let randomName = answers.random()
        let ind = answers.firstIndex(of: randomName)
        answers.remove(at: ind!)
        return randomName
    }
    
    @IBAction func continueAction(sender:UIButton){
        self.checkAnswer(btn: sender)
        if index < questions!.count - 1 {
            index = index + 1
            self.perform(#selector(updateView), with: nil, afterDelay: 1)
        } else {
            self.perform(#selector(quizDidEnd), with: nil, afterDelay: 1)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func checkAnswer(btn:UIButton){
        let question = questions?[index]
        let bgName = btn.titleLabel?.text == question?.rightAnswer ? "button_bonus_green" : "button_bonus_red"
        self.rightAnswers = btn.titleLabel?.text == question?.rightAnswer ? rightAnswers + 1 : rightAnswers
        self.updateSelectedButton(bgName: bgName, btn: btn)
        self.buttons.forEach {
            $0.isUserInteractionEnabled = false
        }
    }
    
    func updateSelectedButton(bgName:String,btn:UIButton){
        UIView.transition(with: btn, duration: 0.25, options: .transitionCrossDissolve, animations: {
        btn.setBackgroundImage(UIImage(named: bgName), for: .normal)
            btn.setTitleColor(.white, for: .normal)
        }, completion: nil)
    }
    
    @objc func quizDidEnd(){
        
        let percents : Float = Float(rightAnswers) / Float(self.questions!.count)
        let isComplited = percents>successGamePercentage()
        if isComplited == true {
            
            if let firUser = Auth.auth().currentUser {
                let rootRef = Database.database().reference()
                let userRef = rootRef.child("users").child(firUser.uid)
                let levelRef = userRef.child("bonus").child("\(self.bonus!.id)")
                
                var values = [String:AnyObject]()
                values["bonus_complited"] = isComplited as AnyObject
                levelRef.updateChildValues(values)
            }
            
            let levels = Array(try! Realm().objects(UserBonusLevel.self))
            let filteredLevels = levels.filter{$0.id==self.bonus?.id}
            var userLevel = UserBonusLevel()
            if filteredLevels.count > 0 {
                userLevel = filteredLevels.first ?? UserBonusLevel()
            } else {
                userLevel.id = self.bonus!.id
            }
        
            try! Realm().write {
                //userLevel.id = self.level!.id
                userLevel.level_id = self.bonus!.levelNumber
                userLevel.complitePercent = Int(percents)
                userLevel.complited = isComplited
                realm?.add(userLevel, update: .all)
            }
            
            
            
        }
        let identifier = percents >= 0.4 ? "complite" : "fail"
        let controller = self.storyboard?.instantiateViewController(identifier: identifier) as? BonusGameCompleteController
        controller?.bonus = self.bonus
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    func successGamePercentage() -> Float {
        let percentage = (try! Realm().objects(Settings.self).first?.successGamePercentage)
        return Float(percentage ?? 100)/100.0
    }
}
