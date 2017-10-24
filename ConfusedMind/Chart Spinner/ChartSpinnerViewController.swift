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
import AVFoundation

class ChartSpinnerViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var itemsView: PieChartView!
    @IBOutlet weak var emptyChartView: UIView!
    @IBOutlet weak var spinButton: UIButton!
    
    @IBOutlet weak var speakerButton: UIButton!
    
    var managedContext = ManagedContext()
    var items : [NSManagedObject] = []
    
    var seconds = 2
    var timer = Timer()
    var isTimerRunning = false
    

    var isSpeakerEnabled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            
        } else {
            // Fallback on earlier versions
        }
        
        itemsView.noDataText = "No data"
        itemsView.chartDescription?.text = ""
        emptyChartView.isHidden = true
        itemsView.isHidden = true
        spinButton.isHidden = true
        itemsView.noDataTextColor = ColorPalette.darkRed
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        itemsView.noDataText = "No data"
        items = managedContext.fetchItems()

        guard items.count != 0 else {
            emptyChartView.isHidden = false
            itemsView.isHidden = true
            spinButton.isHidden = true
            return
        }
        
        emptyChartView.isHidden = true
        itemsView.isHidden = false
        spinButton.isHidden = false
        setChart(dataPoints: items)
        
        /**
         Notify PieChart about the change
         */
        itemsView.notifyDataSetChanged()
        itemsView.delegate = self
    }
    
    @IBAction func spinButtonAction(_ sender: Any) {
        if isTimerRunning == false {
            runTimer()
        }
//        self.itemsView.spin(duration: 2, fromAngle: 0, toAngle: 1080)
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ChartSpinnerViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateTimer() {
        if self.seconds < 0 {
            timer.invalidate()
            //Send alert to indicate time's up.
            let aRandomInt = generateRandomNumber(min:0, max: self.items.count)
            itemsView.highlightValue(x: aRandomInt, y: 0.0, dataSetIndex: 0)
            self.seconds = 2
            isTimerRunning = false
            
            let itemName = items[Int(aRandomInt)].value(forKeyPath: "name") as? String
            let synth = AVSpeechSynthesizer()
            let myUtterance = AVSpeechUtterance(string: itemName!)
            myUtterance.rate = 0.5

            if isSpeakerEnabled {
                synth.speak(myUtterance)
            } else {
                synth.stopSpeaking(at: AVSpeechBoundary.word)
            }
            
        } else {
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
    
    @IBAction func speakerButtonClicked(_ sender: UIButton) {
        let speaker = UIImage(named: "soundSpeaker")
        let mute = UIImage(named: "soundMute")
        guard isSpeakerEnabled else {
            isSpeakerEnabled = true
            sender.setImage(mute, for: UIControlState.normal)
            return
        }
        
        sender.setImage(speaker, for: UIControlState.normal)
        isSpeakerEnabled = false
    }
    
    func setChart(dataPoints: [NSManagedObject]) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let item = self.items[i]
            let itemName = item.value(forKeyPath: "name") as? String
            
            let dataEntry = PieChartDataEntry(value: 1.0, label: itemName, data:  dataPoints[i] as AnyObject)
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
