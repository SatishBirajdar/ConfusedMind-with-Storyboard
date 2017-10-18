//
//  ViewController.swift
//  ConfusedMind
//
//  Created by Satish Birajdar on 2017-08-22.
//  Copyright © 2017 SBSoftwares. All rights reserved.
//

import UIKit
import CoreData

class ItemListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var items : [NSManagedObject] = []
    var presenter: ItemListPresenter = ItemListPresenterImpl()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.automatic
        

//        self.title = "Item List"
        tableView?.dataSource = self
        tableView?.delegate = self
        self.presenter.attachView(view: self)
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Item")
        
        //3
        do {
            items = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
//        let saveAction = UIAlertAction(title: "Save",
//                                       style: .default) {
//                                        [unowned self] action in
//
//                                        guard let textField = alert.textFields?.first,
//                                            let nameToSave = textField.text else {
//                                                return
//                                        }
//                                        let newItem = Item.init(name: nameToSave)
//                                        self.items?.append(newItem)
//                                        self.tableView.reloadData()
//        }
        
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }

        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func save(name: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Item",
                                       in: managedContext)!
        
        let item = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        item.setValue(name, forKeyPath: "name")
        
        // 4
        do {
            try managedContext.save()
            items.append(item)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension ItemListViewController: ItemListPresenterView {
    func displayItems(items: [Item]) {
        self.items = items
    }
}

extension ItemListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
//        people[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableCell
        cell.itemName.text = item.value(forKeyPath: "name") as? String
//            Item?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.items.count)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension ItemListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.isSelected = true
    }
}

class ItemTableCell: UITableViewCell {
    @IBOutlet weak var itemName: UITextView!
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        let editImage = UIImage.init(named: "editIcon")
        let doneImage = UIImage.init(named: "doneIcon")
        
        if (sender.imageView?.image?.isEqualToImage(image: editImage!))! {
            self.itemName.isEditable = true
            self.itemName.becomeFirstResponder()
            sender.setImage(doneImage, for: .normal)
        } else {
            self.itemName.isEditable = false
            self.itemName.resignFirstResponder()
            sender.setImage(editImage, for: .normal)
        }
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    override var isSelected: Bool
        {
        didSet{
            if (isSelected)
            {
                print("custom row selected \(self.itemName.text)")
            }
            else
            {
                print("custom row not selected")
            }
        }
    }
}




