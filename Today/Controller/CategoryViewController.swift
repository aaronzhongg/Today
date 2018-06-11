//
//  CategoryViewController.swift
//  Today
//
//  Created by Aaron Zhong on 11/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    // MARK: - Data Manipulation
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadData() {
        do {
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching request: \(error)")
        }
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
            let newCategory = Category(context: self.context)
            newCategory.name = newCategoryTextField.text!
            self.categoryArray.append(newCategory)
            
            self.saveData()
        }))
        
        addCategoryAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(addCategoryAlert, animated: true)
    }
    
    
}
