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
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var todoItems: Results<TodoItem>?
    let realm = try! Realm()
    
    @IBOutlet weak var todoSearchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
      
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let colourHex = selectedCategory?.backgroundColour else { fatalError() }
        guard let navBarColour = UIColor(hexString: colourHex) else { fatalError() }
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist ")}
        
        title = selectedCategory?.name
    
        todoSearchBar.barTintColor = navBarColour
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
        
        
        
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
            
            if let colour = todoItems?[indexPath.row].parentCategory.first!.backgroundColour! {
                cell.backgroundColor = UIColor.init(hexString: colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat((todoItems?.count)!))
                cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
                cell.accessoryView?.tintColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
                cell.accessoryView?.backgroundColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            }
            
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
            alertTextField.autocapitalizationType = UITextAutocapitalizationType.sentences
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

