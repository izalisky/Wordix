//
//  File.swift
//  Wordix
//
//  Created by Ігор on 10/28/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation

protocol LearnWordsViewModelType {
    var maxTime : Int { get }
    func words() -> [Word] 
    func viewModel() -> GameProcessViewModel?
}
