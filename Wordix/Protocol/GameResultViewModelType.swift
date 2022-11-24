//
//  GameResultViewModelType.swift
//  Wordix
//
//  Created by Ігор on 11/7/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation

protocol GameResultViewModelType {
    var rightWordsCount : Int  {get}
    var allWordsCount : Int {get}
    //var successGamePercentage : Float{get}
    func successGamePercentages() -> Float
    func updateLevel()
    func viewModel() -> OpenLevelViewModelType?
}
