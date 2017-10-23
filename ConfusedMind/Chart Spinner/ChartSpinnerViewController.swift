//
//  SelectItemViewController.swift
//  ConfusedMind
//
//  Created by Satish Birajdar on 2017-10-04.
//  Copyright © 2017 SBSoftwares. All rights reserved.
//

import Foundation
import UIKit
import Charts
import CoreData

class ChartSpinnerViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var itemsView: PieChartView!
    @IBOutlet weak var emptyChartView: UIView!
    @IBOutlet weak var spinButton: UIButton!
    var months: [String]!
    

    
    var managedContext = ManagedContext()
    var items : [NSManagedObject] = []
    
    var seconds = 2
    var timer = Timer()
    
    var isTimerRunning = false
    var resumeTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            
        } else {
            // Fallback on earlier versions
        }
        
        print(itemsView.center)
        print(itemsView.frame.width)
        print(self.view.center.x)
        print(UIScreen.main.bounds.width)
        
        
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
//        label.center = CGPoint(x: itemsView.center.x, y: itemsView.center.y + 90)
//        label.textAlignment = .center
//        label.text = "I'am a test label"
//        self.view.addSubview(label)
        
//        var imageView : UIImageView
//        imageView  = UIImageView(frame:CGRect(x:0, y:0, width:50, height:80))
//        imageView.center = CGPoint(x: self.view.center.x, y: itemsView.center.y + 60)
//        imageView.image = UIImage(named:"redArrow")
//        self.view.addSubview(imageView)
        
        itemsView.noDataText = "No data"
        itemsView.chartDescription?.text = ""
        emptyChartView.isHidden = true
        itemsView.isHidden = false
        itemsView.noDataTextColor = ColorPalette.darkRed
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        itemsView.noDataText = "No data"
        items = managedContext.fetchItems()

        guard items.count != 0 else {
            emptyChartView.isHidden = false
            itemsView.isHidden = true
            return
        }
        
        emptyChartView.isHidden = true
        itemsView.isHidden = false
        setChart(dataPoints: items)
        
        /**
         Notify PieChart about the change
         */
        itemsView.notifyDataSetChanged()
        itemsView.delegate = self
    }
    
    @IBAction func spinButtonAction(_ sender: Any) {
//        let aRandomInt = generateRandomNumber(min:0, max: self.items.count)
        if isTimerRunning == false {
            runTimer()
//            self.startButton.isEnabled = false
        }
//        self.itemsView.spin(duration: 2, fromAngle: 0, toAngle: 1080)
        
        
//        itemsView.highlightValue(x: 0, y: 0.0, dataSetIndex: 0)
//        itemsView.highlightValue(x: 1, y: 0.0, dataSetIndex: 0)
//        itemsView.highlightValue(x: 2, y: 0.0, dataSetIndex: 0)
//        itemsView.highlightValue(x: 3, y: 0.0, dataSetIndex: 0)
//        itemsView.highlightValue(x: 4, y: 0.0, dataSetIndex: 0)
//        itemsView.highlightValue(x: aRandomInt, y: 0.0, dataSetIndex: 0)
//        var selectedData = self.itemsView.data?.getDataSetByIndex(0).entryForIndex(2)
//        print(aRandomInt)
        
        
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ChartSpinnerViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
//        pauseButton.isEnabled = true
    }
    
    
    @objc func updateTimer() {
        if self.seconds < 0 {
            timer.invalidate()
            //Send alert to indicate time's up.
            let aRandomInt = generateRandomNumber(min:0, max: self.items.count)
            itemsView.highlightValue(x: aRandomInt, y: 0.0, dataSetIndex: 0)
            self.seconds = 2
            isTimerRunning = false
        } else {
            print(String(seconds))
            let myString = String(self.seconds)
            let myAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.red, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 25)!, ]
            let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
            
            itemsView.centerAttributedText = myAttrString
            self.seconds -= 1
        }
    }
    
    func generateRandomNumber(min: Int, max: Int) -> Double {
        let randomNum = Int(arc4random_uniform(UInt32(max) - UInt32(min)) + UInt32(min))
        return Double(randomNum)
    }
    
    func setChart(dataPoints: [NSManagedObject]) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let item = self.items[i]
            let itemName = item.value(forKeyPath: "name") as? String
            
            let dataEntry = PieChartDataEntry(value: 1.0, label: itemName, data:  dataPoints[i] as AnyObject)
//            let dataEntry = PieChartDataEntry(value: 1.0, label: dataPoints[i], data:  dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartData.setDrawValues(false)
        self.itemsView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for i in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = colors
    }
}
