//
//  GameProcessController.swift
//  Wordix
//
//  Created by Ігор on 11/6/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
import RealmSwift


class GameProcessController: UIViewController, TagListViewDelegate {
    @IBOutlet weak var tagListView : TagListView!
    @IBOutlet weak var tagListViewHeight : NSLayoutConstraint!
    @IBOutlet weak var scrollView : UIScrollView!
    var viewModel : GameProcessViewModelType?
    var rightColor = UIColor(red: 0.026, green: 0.771, blue: 0.654, alpha: 1)
    var wrongColor = UIColor(red: 0.917, green: 0.378, blue: 0.344, alpha: 1)
    
    @IBOutlet weak var wordsCountLabel : UILabel!
    @IBOutlet weak var rightWordsCountLabel : UILabel!
    @IBOutlet weak var leftClicksLabel : UILabel!
    @IBOutlet weak var topGradient : UIImageView!
    @IBOutlet weak var bottomGradient : UIImageView!
    var gradientGenerated = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient(colors: Constants.gradientColors3)
        self.configureTagsView()
        self.setupTags()
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width-40, height: (tagListView.tagViewHeight + 10) * CGFloat(tagListView.rows)+60)
        self.updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width-40, height: (tagListView.tagViewHeight + 10) * CGFloat(tagListView.rows)+60)
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
        tagView.onTap = { tagView in
            let isRightClick = self.viewModel?.isRightWord(word: tagView.word!)
            tagView.setTitleColor(.white, for: .normal)
            tagView.tagBackgroundColor = isRightClick == true ? self.rightColor : self.wrongColor
            tagView.isEnabled = false
            self.viewModel?.didClick(word: tagView.word!)
            self.updateUI()
            if self.viewModel?.clicksLeft() == 0 {
                self.performSegue(withIdentifier: "result", sender: nil)
            }
        }
    }
    
    func updateUI(){
        self.rightWordsCountLabel.text = "\((self.viewModel?.rightClicksCount())!)"
        self.leftClicksLabel.text = self.viewModel?.clicksLeftCount()
        self.wordsCountLabel.text = "\((self.viewModel?.rightWordsCount())!)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as? GameResultController
        dvc?.viewModel = self.viewModel?.resultViewModel()
    }
    
    
}
