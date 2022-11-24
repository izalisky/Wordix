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

class OpenWordController: UIViewController {
    @IBOutlet weak var slideshowView : UIView?
    @IBOutlet weak var slideshow_right_btn : UIButton?
    @IBOutlet weak var slideshow_left_btn : UIButton?
    @IBOutlet weak var cardLabel : UILabel!
    @IBOutlet weak var numberLabel : UILabel!
    @IBOutlet weak var cardImage : UIImageView!
    var speechSynthesizer = AVSpeechSynthesizer()
    weak var delegate : LearnWordsController!
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
            if self.delegate.paused == false && self.slideshow == true {
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
            self.perform(#selector(runTimer), with: nil, afterDelay: slideshowTimeStep)
        }
        try! Realm().write() {
            self.currentWord?.learned = true
            try! Realm().add(self.currentWord!, update: Realm.UpdatePolicy.modified)
        }
        let index = self.words!.firstIndex(of: self.currentWord!)
        numberLabel.text = "\(index!+1)/\((self.words?.count)!)"
        self.cardLabel.text = self.currentWord?.name
        self.cardImage.af.setImage(withURL: URL(string: (currentWord?.imageUrl())!)!, placeholderImage: UIImage())
        self.updateNextPrevButtons()
        if self.speechEnabled == true {
            self.speechText(text: self.currentWord!.name);
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
        let language = try! Realm().objects(Language.self).filter("current == true").first
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechUtterance.voice = AVSpeechSynthesisVoice(language: language?.code)
        speechSynthesizer.speak(speechUtterance)
    }
    
    func reset(){
        self.view.removeFromSuperview()
        self.slideshow = false
        self.timer?.invalidate()
        self.timer = nil
    }

}
