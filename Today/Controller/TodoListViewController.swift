//
//  ViewController.swift
//  Today
//
//  Created by Aaron Zhong on 8/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [TodoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        itemArray.append(TodoItem(newItemTitle: "Pick up Stephanie @ 1.30pm"))
        
    }

    // MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        let cellItem = itemArray[indexPath.row]
        
        cell.textLabel!.text = cellItem.title
        
        cell.accessoryType = cellItem.completed ? .checkmark : .none
        
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].completed = !itemArray[indexPath.row].completed
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var newTodoTextField = UITextField()
        
        let addItemAlert = UIAlertController(title: "Add New Todo", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (alertAction) in
            
            if newTodoTextField.text != nil {
                self.itemArray.append(TodoItem(newItemTitle: newTodoTextField.text!))
                
                self.tableView.reloadData()
            }
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        addItemAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New todo"
            newTodoTextField = alertTextField
        }
        addItemAlert.addAction(alertAction)
        addItemAlert.addAction(cancelAlertAction)
        present(addItemAlert, animated: true, completion: nil)
    }
    

}

