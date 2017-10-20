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
    var managedContext = ManagedContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.automatic

        tableView?.dataSource = self
        tableView?.delegate = self
        self.presenter.attachView(view: self)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        //1
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return
//        }
//
//        let managedContext =
//            appDelegate.persistentContainer.viewContext
//
//        //2
//        let fetchRequest =
//            NSFetchRequest<NSManagedObject>(entityName: "Item")
//
//        //3
//        do {
//            items = try managedContext.fetch(fetchRequest)
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
        
        items = managedContext.fetchItems()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @IBAction func editList(_ sender: UIBarButtonItem) {
        if sender.title == "Edit" {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
        } else {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
        }
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in

            let textField = alert.textFields?.first
            
            guard let nameToSave = textField?.text,  textField?.text != "" else {
                print("Textfield is empty")
                    return
            }
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)

        alert.addTextField { (textField) in
            textField.autocapitalizationType = .words
        }

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func save(name: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext

        let entity =
            NSEntityDescription.entity(forEntityName: "Item",
                                       in: managedContext)!

        let item = NSManagedObject(entity: entity,
                                     insertInto: managedContext)

        item.setValue(name, forKeyPath: "name")

        do {
            try managedContext.save()
            items.append(item)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
//        self.managedContext.saveItem(name: name)
//        items.append(item)
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

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableCell
        cell.itemName.text = item.value(forKeyPath: "name") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.items.count)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        if editingStyle == .delete {
            // Delete the row from the data source
            print("item deleted")
            let itemToDelete = items[indexPath.row]
            items.remove(at: indexPath.row)
            managedContext.delete(itemToDelete)
            do {
                try managedContext.save()
                tableView.deleteRows(at: [indexPath], with: .left)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
         }
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
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return
//        }
//        
//        let managedContext =
//            appDelegate.persistentContainer.viewContext
//        
//        let fetchRequest =
//            NSFetchRequest<NSManagedObject>(entityName: "Item")
//        
//        var items = [NSManagedObject]()
//        //3
//        do {
//            items = try managedContext.fetch(fetchRequest)
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
        
        
        
        
        let editImage = UIImage.init(named: "editItem")
        let doneImage = UIImage.init(named: "doneEditItem")
        
        if (sender.imageView?.image?.isEqualToImage(image: editImage!))! {
            self.itemName.isEditable = true
            self.itemName.becomeFirstResponder()
            sender.setImage(doneImage, for: .normal)
            
            
        } else {
            self.itemName.isEditable = false
            self.itemName.resignFirstResponder()
            sender.setImage(editImage, for: .normal)
            
//            let entity =
//                NSEntityDescription.entity(forEntityName: "Item",
//                                           in: managedContext)!
//
//            let item = NSManagedObject(entity: entity,
//                                       insertInto: managedContext)
//
//            item.setValue(self.itemName.text, forKeyPath: "name")
//
//            items[sender.tag] = item
//
//            do {
//                try managedContext.save()
//
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
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
