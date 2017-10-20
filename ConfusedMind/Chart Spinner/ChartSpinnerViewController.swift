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
    var months: [String]!
    
    @IBOutlet weak var spinButton: UIButton!
    
    var managedContext = ManagedContext()
    var items : [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true

        
        
        itemsView.noDataText = "No data"
//        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        
//        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        
        
//        let item = self.items[indexPath.row]
//        cell.itemName.text = item.value(forKeyPath: "name") as? String
        
        
       
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        items = managedContext.fetchItems()
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
        setChart(dataPoints: items)
        /**
         Notify PieChart about the change
         */
        itemsView.notifyDataSetChanged()
        itemsView.delegate = self
    }
    
    @IBAction func spinButtonAction(_ sender: Any) {
        self.itemsView.spin(duration: 3, fromAngle: 0, toAngle: 1000)
        var selectedData = self.itemsView.data?.getDataSetByIndex(0).entryForIndex(2)
        itemsView.highlightValue(x: 4.0, y: 0.0, dataSetIndex: 0)
    }
    
    func setChart(dataPoints: [NSManagedObject]) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let item = self.items[i]
            let itemName = item.value(forKeyPath: "name") as? String
            
            let dataEntry = PieChartDataEntry(value: 1.0, label: itemName, data:  dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Units Sold")
        
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
