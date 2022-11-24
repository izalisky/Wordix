//
//  Chart.swift
//  Wordix
//
//  Created by Ігор on 11/8/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit

class Chart: UIView {
    private let mainLayer: CALayer = CALayer()
    private let scrollView: UIScrollView = UIScrollView()
    private var animated = false
    private let presenter = ChartPresenter(barWidth: 20, space: (UIScreen.main.bounds.size.width - 54 - 140)/8)
    private var barEntries: [Entry] = [] {
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
            
            scrollView.contentSize = CGSize(width: presenter.computeContentWidth(), height: self.frame.size.height)
            mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
            
            for (index, entry) in barEntries.enumerated() {
                showEntry(index: index, entry: entry, animated: animated, oldEntry: oldValue.safeValue(at: index))
            }
        }
    }
    
    func updateDataEntries(dataEntries: [DataEntry], animated: Bool) {
        self.animated = animated
        self.presenter.dataEntries = dataEntries
        self.barEntries = self.presenter.computeBarEntries(viewHeight: self.frame.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        scrollView.layer.addSublayer(mainLayer)
        self.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateDataEntries(dataEntries: presenter.dataEntries, animated: false)
    }
    
    private func showEntry(index: Int, entry: Entry, animated: Bool, oldEntry: Entry?) {
        let cgColor = entry.data.color.cgColor
        mainLayer.addRectangleLayer(frame: entry.barFrame, color: cgColor, animated: animated, oldFrame: oldEntry?.barFrame)
        mainLayer.addTextLayer(frame: entry.textValueFrame, color: cgColor, fontSize: 14, text: entry.data.textValue, animated: animated, oldFrame: oldEntry?.textValueFrame)
        mainLayer.addTextLayer(frame: entry.bottomTitleFrame, color: cgColor, fontSize: 14, text: entry.data.title, animated: animated, oldFrame: oldEntry?.bottomTitleFrame)
    }
}
