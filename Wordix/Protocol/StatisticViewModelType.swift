//
//  StatisticViewModelType.swift
//  Wordix
//
//  Created by Ігор on 11/8/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation

protocol StatisticViewModelType {
    func averageWords()->Int
    func mostWords()->Int
    func allRememberedWords()->Int
    func wordPerDate(date:Date)->Int
    func wordsCountString() -> String 
}
