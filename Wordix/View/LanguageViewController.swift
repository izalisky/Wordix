//
//  LanguageViewController.swift
//  Wordix
//
//  Created by Ігор on 10/24/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController {
     var from_main_screen : Bool?
    var viewModel : LanguageViewModelType?
    @IBOutlet weak var footerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient(colors: Constants.gradientColors1)
        self.viewModel = LanguageViewModel()
        _ = viewModel?.currentLanguage()
        self.viewModel?.setupButtons(view: self.view)
        footerLabel.text = NSLocalizedString("tbc_lang", comment: "")
    }
    
    @IBAction func doneAction(){
        if from_main_screen == true {
            self.navigationController?.popViewController(animated: true)
        } else {
            /*let controller = UIStoryboard(name: "Subscription", bundle: .main).instantiateViewController(identifier: "subscription") as? SubscriptionViewController
            self.navigationController?.pushViewController(controller!, animated: true)*/
            let controller = UIStoryboard(name: "Auth", bundle: .main).instantiateViewController(identifier: "auth") as? AuthViewController
            self.navigationController?.pushViewController(controller!, animated: true)
        }
    }
    
    @IBAction func selectLanguageAction(sender:UIButton){
        viewModel?.buttons.forEach{
            $0.isSelected = $0.tag == sender.tag
        }
        viewModel?.selectLanguage(index:sender.tag-1)
        doneAction()
    }
}
