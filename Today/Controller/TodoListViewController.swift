//
//  ViewController.swift
//  Today
//
//  Created by Aaron Zhong on 8/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [TodoItem]()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("todoItems.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
//        loadItems()
    }

    // MARK: - Tableview Datasource Methods
    
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
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].completed = !itemArray[indexPath.row].completed
        
        saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var newTodoTextField = UITextField()
        
        let addItemAlert = UIAlertController(title: "Add New Todo", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (alertAction) in
            
            if newTodoTextField.text != nil {
                let newItem = TodoItem(context: self.context)
                
                newItem.title = newTodoTextField.text!
                newItem.completed = false
                newItem.parentCategory = self.selectedCategory
                
                self.itemArray.append(newItem)
                self.saveItems()
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
    
    // MARK: - Model Manipulation
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func loadItems(with request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching context: \(error)")
        }
    }
}

// MARK: - Search Bar

extension TodoListViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 2 {
            let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
            
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request, predicate: predicate)
            
        } else {
            loadItems()
        }
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}

