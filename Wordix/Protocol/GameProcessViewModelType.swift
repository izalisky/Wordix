//
//  GameProcessModelType.swift
//  Wordix
//
//  Created by Ігор on 11/6/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation

protocol GameProcessViewModelType {
    func clicksLeftCount()->String
    func rightClicksCount()->Int
    func didClick(word:Word)
    func words() -> [Word]
    func resultViewModel() -> GameResultViewModelType?
    func rightWordsCount()->Int
    func clicksLeft()->Int
    func isRightWord(word:Word)->Bool
}
