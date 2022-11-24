//
//  BonusGameCompleteController.swift
//  Wordix
//
//  Created by Ігор on 11/3/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit

class BonusGameCompleteController: UIViewController {
    var bonus : Bonus?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient(colors: Constants.gradientColorsBonus)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func popAction(){
        //self.navigationController?.popToViewController(self.popController(), animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func popController()->UIViewController{
        let controller = self.navigationController?.viewControllers.filter{$0 is OpenLevelViewController}.first
        return controller!
    }
}
