//
//  OpenLevelViewModelType.swift
//  Wordix
//
//  Created by Ігор on 10/27/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
protocol OpenLevelViewModelType : class {
    
    var name : String { get }
    var words : String { get }
    var imageUrl : String { get }
    var isComplited : Bool { get }
    var rightWords: String  { get }
    var image: UIImage?  { get }
    
    func wordsForCurrentLevel() -> [Word]
    func bonusForCurrentLevel() -> Bonus
    func viewModel() -> LearnWordsViewModel?
    func goalForCurrentLevel() -> String
    
}
