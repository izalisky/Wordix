//
//  StatisticViewController.swift
//  Wordix
//
//  Created by Ігор on 10/28/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit

class StatisticViewController: UIViewController {
    @IBOutlet weak var averageWordsLabel : UILabel!
    @IBOutlet weak var mostWordsLabel : UILabel!
    @IBOutlet weak var allWordsLabel : UILabel!
    @IBOutlet weak var chart: Chart!
    var statisticViewModel : StatisticViewModelType?
    private let numEntry = 7

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient(colors: Constants.gradientColorsStatistic)
        self.statisticViewModel = StatisticViewModel()
        self.averageWordsLabel.text = "\((statisticViewModel?.averageWords())!)"
        self.mostWordsLabel.text = "\((statisticViewModel?.mostWords())!)"
        self.allWordsLabel.text = statisticViewModel?.wordsCountString()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dataEntries = self.generateDataEntries()
        self.chart.updateDataEntries(dataEntries: dataEntries, animated: true)
    }
    
    func generateDataEntries() -> [DataEntry] {
        var array = [Int]()
        var maxElement = 1
        for i in 0..<numEntry {
            let date = Date().addingTimeInterval(TimeInterval(-86400*i))
            let element = self.statisticViewModel?.wordPerDate(date: date)
            if element! > maxElement {
                maxElement = element!
            }
            array.append(element!)
        }
        
        var result: [DataEntry] = []
        array.forEach {
            let value = $0
            var height: Float = Float(value)/Float(maxElement)
            height = height + 0.1
            /*let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60*i))*/
            result.append(DataEntry(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2), height: height, textValue: "", title: "\(value)"))
        }
        return result
    }
}
