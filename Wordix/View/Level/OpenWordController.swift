//
//  WordCardViewController.swift
//  Wordix
//
//  Created by Ігор on 10/30/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift
import Firebase

class OpenWordController: UIViewController {
    @IBOutlet weak var slideshowView : UIView?
    @IBOutlet weak var slideshow_right_btn : UIButton?
    @IBOutlet weak var slideshow_left_btn : UIButton?
    @IBOutlet weak var cardLabel : UILabel!
    @IBOutlet weak var numberLabel : UILabel!
    @IBOutlet weak var cardImage : UIImageView!
    var speechSynthesizer = AVSpeechSynthesizer()
    var timer : Timer?
    var currentWord : Word?
    var words : [Word]?
    var speechEnabled = true
    var slideshow = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient(colors: Constants.gradientColors2)
    }
    
    @objc func runTimer(){
        self.timer = Timer.scheduledTimer(withTimeInterval: slideshowTimeStep, repeats: true) { timer in
            if self.slideshow == true {
                self.nextWordAction()
            }
        }
    }
    
    @IBAction func nextWordAction(){
        if let word = self.words?.after(item: self.currentWord!) {
            self.currentWord = word
            self.updateCard()
        }
    }
    
    @IBAction func prevWordAction(){
        if let word = self.words?.before(item: self.currentWord!) {
            self.currentWord = word
            self.updateCard()
        }
    }
    

     func updateCard(){
        guard self.words!.count > 0 else {return}
        if self.slideshow == true && self.timer == nil {
            self.perform(#selector(runTimer), with: nil, afterDelay: 0)
        }
        
        
        self.updateWord()
        
        let index = self.words!.firstIndex(of: self.currentWord!)
        numberLabel.text = "\(index!+1)/\((self.words?.count)!)"
        self.cardLabel.text = self.currentWord?.name
        self.cardImage.image  = currentWord?.image
        self.cardImage.layer.cornerRadius = 8
        self.updateNextPrevButtons()
        if self.speechEnabled == true {
            self.speechText(text: self.currentWord!.name);
        }
    }
    
    func updateWord(){
    
        if let user = Auth.auth().currentUser {
            let rootRef = Database.database().reference()
            let userRef = rootRef.child("users").child(user.uid)
            let levelRef = userRef.child("words").child("\(self.currentWord!.id)")
            levelRef.updateChildValues(["learned":true])
        }
        
        let words = Array(try! Realm().objects(UserWord.self))
        let fwords = words.filter{$0.id==self.currentWord?.id}
        if fwords.count > 0 {
            try! Realm().write {
                let word = fwords.first
                word?.learned = true
                try! Realm().add(word!, update: Realm.UpdatePolicy.modified)
            }
        } else {
            try! Realm().write {
            let userWord = UserWord()
            userWord.id = self.currentWord!.id
            userWord.learned = true
            try! Realm().add(userWord)
            }
        }
    }
    
       
    func updateNextPrevButtons(){
        self.slideshow_left_btn?.isEnabled = words?.first != self.currentWord
        self.slideshow_right_btn?.isEnabled = words?.last! != self.currentWord
    }
    
    @IBAction func speechAction(){
        self.speechText(text: self.currentWord?.name ?? "")
    }
    
    func speechText(text:String){
        let language = Language.currentLanguage()
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechUtterance.voice = AVSpeechSynthesisVoice(language: language.code)
        speechSynthesizer.speak(speechUtterance)
    }
    
    func reset(){
        self.slideshow = false
        self.timer?.invalidate()
        self.timer = nil
        self.view.removeFromSuperview()
    }

}
