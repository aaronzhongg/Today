//
//  ViewController.swift
//  Today
//
//  Created by Aaron Zhong on 8/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {

    var todoItems: Results<TodoItem>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadItems()
    }

    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        if let cellItem = todoItems?[indexPath.row] {
            cell.textLabel!.text = cellItem.title
            
            cell.accessoryType = cellItem.completed ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items"
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.completed = !item.completed
                }
            } catch {
                print("Error saving completed status: \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var newTodoTextField = UITextField()
        
        let addItemAlert = UIAlertController(title: "Add New Todo", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (alertAction) in
            
            if newTodoTextField.text != nil {
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newTodoItem = TodoItem()
                            newTodoItem.title = newTodoTextField.text!
                            newTodoItem.completed = false
                            currentCategory.todoItems.append(newTodoItem)
                        }
                    } catch {
                        print("Error saving new items: \(error)")
                    }
                    
                    self.tableView.reloadData()
                }
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
    
//    func saveItems() {
//
//        do {
//            try context.save()
//        } catch {
//            print(error)
//        }
//    }
    
    func loadItems() {
        todoItems = selectedCategory?.todoItems.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

// MARK: - Search Bar

//extension TodoListViewController: UISearchBarDelegate {
////    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
////
////    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.count > 2 {
//            let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
//
//            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
//
//            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//            loadItems(with: request, predicate: predicate)
//
//        } else {
//            loadItems()
//        }
//
//        tableView.reloadData()
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        DispatchQueue.main.async {
//            searchBar.resignFirstResponder()
//        }
//    }
//}

