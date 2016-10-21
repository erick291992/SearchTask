//
//  ViewController.swift
//  SearchTask
//
//  Created by Erick Manrique on 10/19/16.
//  Copyright © 2016 AppsAtHome. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var cashButton: UIButton!
    
    var items = [Item]()
    var filteredItems = [Item]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.searchBar.translucent = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All", "Category"]
        
        topView.addSubview(searchController.searchBar)
        parseCSV()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.searchController.searchBar.sizeToFit()
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.tintAdjustmentMode = UIViewTintAdjustmentMode.Normal
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cashButtonPressed(sender: AnyObject) {
        if !searchController.active{
            items = items.sort {$0.price < $1.price}
        }
        else{
            items.removeAll()
            parseCSV()
        }
        if searchController.searchBar.text != "" {
            filteredItems = filteredItems.sort {$0.price < $1.price}
        }
        tableView.reloadData()
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredItems.count
        }
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let item: Item
        if searchController.active && searchController.searchBar.text != ""{
            item = filteredItems[indexPath.row]
        }
        else {
            item = items[indexPath.row]
        }
        cell.textLabel!.text = item.item_description
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        let price = formatter.stringFromNumber(item.price)!
        cell.detailTextLabel!.text = "\(item.category) - \(price)"
        return cell
    }
    
    // MARK: - formats the csv file to an array of data
    func parseCSV(){
        let path = NSBundle.mainBundle().pathForResource("inventory", ofType: "csv")
        do{
            let csv = try CSV.init(contentsOfURL: path!)
            let rows = csv.rows
            for row in rows{
                var price = row["Price"]!
                price.removeAtIndex(price.startIndex)
                let item = Item(item_description: row["Item"]!, qty: Int(row["Qty."]!)!, price: Double(price)!, category: row["Category"]!)
                items.append(item)
            }
        }catch{
            
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredItems = items.filter({( item : Item) -> Bool in
            if scope == "Category"{
                return item.category.lowercaseString.containsString(searchText.lowercaseString)
            }
            else{
                return item.item_description.lowercaseString.containsString(searchText.lowercaseString)
            }
        })
        tableView.reloadData()
    }
    
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

