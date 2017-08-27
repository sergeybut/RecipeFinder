//
//  SearchRecipeViewController.swift
//  RecipeFinder
//
//  Created by sergey on 8/15/17.
//  Copyright © 2017 sergey. All rights reserved.
//

import UIKit

class SearchRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    
    var recipes = NSArray()
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - API Stuff
    
    func searchRecipe(_ recipeName: String) {
        RecipePappy.request(.recipe(recipeName)) { result in
            do {
                let response = try result.dematerialize()
                let value = try response.mapNSDictionary()
                self.recipes = value["results"] as! NSArray
                self.tableView.reloadData()
            } catch {
                print("Enable to reach recipt, error: \(error)")
            }
        }
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count < 20 ? recipes.count : 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        let repo = recipes[indexPath.row] as? NSDictionary
        cell.textLabel?.text = repo?["title"] as? String
        cell.detailTextLabel?.text = ""
        
        return cell
    }
}

extension SearchRecipeViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchRecipeText = searchController.searchBar.text!
        
        searchRecipe(searchRecipeText)
    }
}

