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

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added Yet"
        
        return cell
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
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
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
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
