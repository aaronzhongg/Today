//
//  CategoryViewController.swift
//  Today
//
//  Created by Aaron Zhong on 11/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        tableView.rowHeight = 80
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        
        return cell
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    
    // MARK: - Data Manipulation
    
    func saveData(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadData() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
//    func deleteCategory(category: Category) {
//
//    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let addCategoryAlert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        var newCategoryTextField = UITextField()
        
        addCategoryAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category name"
            newCategoryTextField = alertTextField
        }
        
        addCategoryAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (alertAction) in
            // Add new category
            let newCategory = Category()
            newCategory.name = newCategoryTextField.text!
            
            self.saveData(category: newCategory)
        }))
        
        addCategoryAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(addCategoryAlert, animated: true)
    }
    
}

// MARK: - Swipe Cell Delegate

extension CategoryViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            if let categoryToDelete = self.categories?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(categoryToDelete)
                        
                    }
                } catch {
                    print("Error deleting category: \(error)")
                }
//                tableView.reloadData()
            }
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}
