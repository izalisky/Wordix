//
//  OnboardingViewModelType.swift
//  Wordix
//
//  Created by Ігор on 11/3/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation

protocol OnboardingViewModelType {
    func loadContentIfNeed()
    var loadingContentDidFinish: (() -> Void)?{get set}
    var loadingContentChangeProgress: ((Int) -> Void)?{get set}
}
