//
//  ViewController.swift
//  Today
//
//  Created by Aaron Zhong on 8/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class TodoListViewController: SwipeTableViewController {

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
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
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
                            newTodoItem.dateCreated = Date()
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
    
    func loadItems() {
        todoItems = selectedCategory?.todoItems.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func deleteItem(at indexPath: IndexPath) {
        if let todoItem = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(todoItem)
                }
            } catch {
                print("Error deleting item: \(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("Delete cell")
            self.deleteItem(at: indexPath)
        }
        
        // customize the action appearance
        //        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
}

// MARK: - Search Bar

extension TodoListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 2 {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
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

