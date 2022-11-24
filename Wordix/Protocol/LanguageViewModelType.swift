//
//  LanguageViewModelType.swift
//  Wordix
//
//  Created by Ігор on 10/29/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import UIKit
 
protocol LanguageViewModelType {
    var buttons : [UIButton] { get }
    func allLanguages() -> [Language]
    func currentLanguage() -> Language
    func selectLanguage(index:Int)
    func setupButtons(view:UIView)
}
