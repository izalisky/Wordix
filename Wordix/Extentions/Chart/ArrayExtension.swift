//
//  ArrayExtension.swift
//  Wordix
//
//  Created by Ігор on 11/8/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation

extension Array {
    func safeValue(at index: Int) -> Element? {
        if index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
}
