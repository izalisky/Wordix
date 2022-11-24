//
//  ViewController.swift
//  Wordix
//
//  Created by Ігор on 10/24/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
import RealmSwift

class OnboardingViewController: UIViewController {
    @IBOutlet weak var onboarding_text_label_1 : UILabel?
    @IBOutlet weak var onboarding_text_label_2 : UILabel?
    @IBOutlet weak var onboarding_text_label_3 : UILabel?
    @IBOutlet weak var onboarding_text_label_4 : UILabel?
    @IBOutlet weak var onboarding_text_label_5 : UILabel?
    @IBOutlet weak var onboarding_text_label_6 : UILabel?
    @IBOutlet weak var onboarding_text_label_7 : UILabel?
    @IBOutlet weak var splash : UIView?
    @IBOutlet weak var continue_btn : UIButton?
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel : UILabel?
    
    var finish = false
    
    var viewModel : OnboardingViewModelType?
    let realm = try? Realm()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient(colors: Constants.gradientColors1)
        self.viewModel = OnboardingViewModel()
        self.viewModel?.loadContentIfNeed()
        self.viewModel?.loadingContentDidFinish = {
            UIView.animate(withDuration: 0.25) {
                self.splash?.alpha = 0.0
            }
        }
        
        self.viewModel?.loadingContentChangeProgress = { progress in
            let loadingText = NSLocalizedString("loading_text", comment: "")
            self.progressLabel?.text = "\(loadingText)" //"\(loadingText)\n\(progress)%"
            self.progressView.setProgress(Float(progress)/100.0, animated: true)
        }
    }
}

