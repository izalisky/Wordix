//
//  WordsViewController.swift
//  Wordix
//
//  Created by Ігор on 10/25/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
import RealmSwift

class LearnWordsController: UIViewController, TagListViewDelegate {
    @IBOutlet weak var timeView : UIView!
    @IBOutlet weak var timeViewContinueBtn : UIButton!
    @IBOutlet weak var timeViewInfoLabel : UILabel!
    @IBOutlet weak var tagListView : TagListView!
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var runSlidShowButton : UIButton!
    @IBOutlet weak var speechBtn : UIButton!
    @IBOutlet weak var speechBtnOffsetX : NSLayoutConstraint!
    @IBOutlet weak var speechView : UIView!
    @IBOutlet weak var timerLabel : UILabel!
    
    @IBOutlet weak var bottomGradient : UIImageView!
    @IBOutlet weak var topGradient : UIImageView!
    @IBOutlet weak var buttonComplete: UIButton!
    
    var currentWord : Word?
    var viewModel : LearnWordsViewModelType?
    var wordCard : OpenWordController?
    var speechEnabled = true
    var timer : Timer?
    var maxTime = 0
    var paused = false
    var gradientGenerated = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient(colors: Constants.gradientColors2)
        self.timeView.addGradient(colors: Constants.gradientColors2)
        maxTime = self.viewModel!.maxTime
        self.configureTagsView()
        self.setupTags()
        runTimer()
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width-40, height: (tagListView.tagViewHeight + 10) * CGFloat(tagListView.rows))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width-40, height: (tagListView.tagViewHeight + 10) * (CGFloat(tagListView.rows)) + 60)
        if self.gradientGenerated == false {
            self.addGradient(view: topGradient, top: true)
            self.addGradient(view: bottomGradient, top: false)
            self.gradientGenerated = true
        }
    }
    
    func addGradient(view:UIImageView, top:Bool){
        let v = self.view.viewWithTag(321)
        if let img = v?.toImage() {
            let scale = UIScreen.main.scale
            let ni = img.cropImage(rect: CGRect(x: 0.0, y: view.frame.origin.y*scale, width: view.frame.size.width*scale, height: view.frame.size.height*scale))
            let y = top ? 0.0 : view.frame.size.height*scale
            let point = CGPoint(x: 0, y: y)
            let color = ni.getPixelColor(pos: point)
            let colors = top ? [color.cgColor,color.withAlphaComponent(0.0).cgColor] : [color.withAlphaComponent(0.0).cgColor,color.cgColor]
            view.addTransparentGradient(colors: colors)
        }
    }
    
    
    func runTimer(){
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.paused == false {
            self.maxTime = self.maxTime - 1
                self.timerLabel.text = String(format: "%02d:%02d", self.maxTime/60, self.maxTime%60)
            }
            if self.maxTime == 0 {
                self.timer?.invalidate()
                self.showTimeViewInfo(text: NSLocalizedString("Time has finished", comment: "LOC_STR"))
            }
        }
    }
    
    func configureTagsView(){
        tagListView.textFont = UIFont(name: "Gilroy-Bold", size: 20)!
        tagListView.alignment = .leading
        tagListView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
    }
    
    func setupTags(){
        self.viewModel?.words().forEach{
            self.addTag(word: $0)
        }
    }
    
    func addTag(word : Word){
        let tagView = tagListView.addTag(word.name)
        tagView.word = word
        tagView.backgroundColor = word.isLearned() == false ? tagView.backgroundColor : tagView.backgroundColor?.withAlphaComponent(0.5)
        tagView.onTap = { tagView in
            self.openCard(open: true, slideshow: false)
            self.currentWord = tagView.word
            self.showCard(slideshow: false)
            self.buttonComplete.isHidden = true
        }
    }
    
    @IBAction func pauseAction(){
        self.paused = true
        showTimeViewInfo(text: NSLocalizedString("Game paused", comment: "LOC_STR"))
        self.wordCard?.timer?.invalidate()
        
    }
    
    func showTimeViewInfo(text:String){
        self.timeViewInfoLabel.text = text
        UIView.animate(withDuration: 0.25) {
            self.timeView.alpha = 1.0
        }
    }
    
    @IBAction func continueAction(){
        if maxTime > 0 {
            self.paused = false
            UIView.animate(withDuration: 0.25) {
                self.timeView.alpha = 0.0
            }
            self.wordCard?.runTimer()
        } else {
            
            let controller = UIStoryboard(name: "GameProcess", bundle: .main).instantiateViewController(identifier: "game") as? GameProcessController
            controller?.viewModel = self.viewModel?.viewModel()
            self.navigationController?.pushViewController(controller!, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.wordCard?.reset()
        self.wordCard = nil
        let dvc = segue.destination as? GameProcessController
        dvc?.viewModel = self.viewModel?.viewModel()
    }
    
    @IBAction func runSlidshowAction(){
        guard (self.viewModel?.words().count)! > 0 else { return }
        self.openCard(open: true, slideshow: true)
        self.currentWord = self.viewModel?.words().first
        self.showCard(slideshow: true)
        buttonComplete.isHidden = true
    }
    
    @IBAction func closeSlideShowAction(){
        UIView.animate(withDuration: 0.25, animations: {
            self.wordCard?.view.alpha = 0.0
        }) { (success) in
            self.wordCard?.reset()
            self.wordCard = nil
            self.openCard(open: false, slideshow: false)
        }
        self.tagListView.removeAllTags()
        self.setupTags()
        buttonComplete.isHidden = false
    }
    
    func openCard(open:Bool, slideshow:Bool){
        var backgroundName = "orange_btn"
        var title = NSLocalizedString("Run slideshow", comment: "LOC_STR")
        var oldSelector : Selector? = #selector(self.runSlidshowAction)
        var newSelector : Selector? = #selector(self.closeSlideShowAction)
        switch (open,slideshow) {
        case (true,true):
            title = NSLocalizedString("Close slideshow", comment: "LOC_STR")
            self.currentWord = self.viewModel?.words().first
        case (true,false):
            title = NSLocalizedString("Close", comment: "LOC_STR")
        case (false,false):
            backgroundName = "blue_btn"
            oldSelector = #selector(self.closeSlideShowAction)
            newSelector = #selector(self.runSlidshowAction)
            self.currentWord = nil
        default:
            break
        }
        
        self.runSlidShowButton.setTitle(title, for: .normal)
        self.runSlidShowButton.setBackgroundImage(UIImage(named: backgroundName), for: .normal)
        self.runSlidShowButton.removeTarget(self, action: oldSelector, for: .touchUpInside)
        self.runSlidShowButton.addTarget(self, action: newSelector!, for: .touchUpInside)
    }
    
    func showCard(slideshow:Bool){
        self.wordCard = self.storyboard?.instantiateViewController(identifier: "card") as? OpenWordController
        self.wordCard?.view.alpha = 0.0
        self.wordCard?.view.frame = UIScreen.main.bounds
        self.view.insertSubview((self.wordCard?.view)!, aboveSubview: self.bottomGradient)
        self.wordCard?.currentWord = self.currentWord
        self.wordCard?.words = self.viewModel?.words()
        self.wordCard?.speechEnabled = self.speechEnabled
        self.wordCard?.slideshow = slideshow
        self.wordCard?.updateCard()
        UIView.animate(withDuration: 0.25) {
            self.wordCard?.view.alpha = 1.0
        }
    }
    
    @IBAction func speechBtnAction(){
        self.speechEnabled = !self.speechEnabled
        self.wordCard?.speechEnabled = self.speechEnabled
        let imageName = self.speechEnabled == true ? "switch_on" : "switch_off"
        let constant = self.speechEnabled == true ? 2.0 : self.speechView.frame.width - self.speechBtn.frame.width-2
        UIView.animate(withDuration:0.25,delay: 0.0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.6,
                       options: .layoutSubviews,
        animations: {
            self.speechBtnOffsetX.constant = constant
            self.speechView.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.speechBtn, duration: 0.25, options: .showHideTransitionViews, animations: {
            self.speechBtn.setImage(UIImage(named: imageName), for: .normal)
        }, completion: nil)
    }
    
    

}
