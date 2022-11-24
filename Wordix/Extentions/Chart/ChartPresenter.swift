//
//  ChartPresenter.swift
//  Wordix
//
//  Created by Ігор on 11/8/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

class ChartPresenter {
    let barWidth: CGFloat
    let space: CGFloat
    private let bottomSpace: CGFloat = 40.0
    private let topSpace: CGFloat = 20.0
    
    var dataEntries: [DataEntry] = []
    
    init(barWidth: CGFloat = 20, space: CGFloat = 20) {
        self.barWidth = barWidth
        self.space = space
    }
    
    func computeContentWidth() -> CGFloat {
        return (barWidth + space) * CGFloat(dataEntries.count) + space
    }
    
    func computeBarEntries(viewHeight: CGFloat) -> [Entry] {
        var result: [Entry] = []
        
        for (index, entry) in dataEntries.enumerated() {
            let entryHeight = CGFloat(entry.height) * (viewHeight - bottomSpace - topSpace)
            let xPosition: CGFloat = space + CGFloat(index) * (barWidth + space)
            let yPosition = viewHeight - bottomSpace - entryHeight
            let origin = CGPoint(x: xPosition, y: yPosition)
            
            let barEntry = Entry(origin: origin, barWidth: barWidth, barHeight: entryHeight, space: space, data: entry)
            
            result.append(barEntry)
        }
        return result
    }
}
