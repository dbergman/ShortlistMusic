//
//  SLSortOptionsVC.swift
//  shortList
//
//  Created by Dustin Bergman on 8/10/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import UIKit

enum ShortlistSortOption: String {
    case YearDescending = "ShortList Year Descending"
    case YearAscending = "ShortList Year Ascending"
    case UpdatedDateDescending = "ShortList Last Updated Date Descending"
    case UpdatedDateAscending = "ShortList Last Updated Date Ascending"

    static let allValues = [YearDescending, YearAscending, UpdatedDateDescending, UpdatedDateAscending]
}

private let sortCellIdentifier = "sortCellIdentifier"
private let shortlistSortOption = "shortlistSortOption"

class SLSortOptionsVC: SLBaseVC, UITableViewDelegate, UITableViewDataSource  {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.blackColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = self.view.bounds
        
        return tableView
    }()
    
    lazy var selectedIndexPath: NSIndexPath = {
        guard let storeSortOption = NSUserDefaults.standardUserDefaults().stringForKey(shortlistSortOption) else { return NSIndexPath(forRow: 0, inSection: 0) }
        guard let row =  ShortlistSortOption(rawValue: storeSortOption) else { return NSIndexPath(forRow: 0, inSection: 0) }

        return NSIndexPath(forRow: row.hashValue, inSection: 0)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sorting Options"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelSort))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(applySort))
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: sortCellIdentifier)
        view.addSubview(tableView)
    }
    
    func cancelSort() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func applySort() {
        dismissViewControllerAnimated(true) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(ShortlistSortOption.allValues[self.selectedIndexPath.row].rawValue, forKey: shortlistSortOption)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ShortlistSortOption.allValues.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(sortCellIdentifier) as UITableViewCell!
        cell.contentView.backgroundColor = UIColor.blackColor()
        cell.backgroundColor = UIColor.blackColor()
        cell.textLabel?.font = SLStyle.polarisFontWithSize(14.0)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.text = ShortlistSortOption.allValues[indexPath.row].rawValue
        cell.selectionStyle = .None
        cell.tintColor = UIColor.sl_Red()
        
        if indexPath.row == selectedIndexPath.row {
            cell.accessoryType = .Checkmark
            cell.textLabel?.textColor = UIColor.sl_Red()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedIndexPath == indexPath {
            return
        }
        
        tableView.cellForRowAtIndexPath(selectedIndexPath)?.accessoryType = .None
        tableView.cellForRowAtIndexPath(selectedIndexPath)?.textLabel?.textColor = UIColor.whiteColor()
        
        selectedIndexPath = indexPath
        
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        tableView.cellForRowAtIndexPath(selectedIndexPath)?.textLabel?.textColor = UIColor.sl_Red()
    }
    
    static func orderShortListForDisplay(shortlists: [SLShortlist]) -> [SLShortlist] {
        var sortOption: ShortlistSortOption
        
        let prefs = NSUserDefaults.standardUserDefaults()

        if let shortlistSortOption = prefs.stringForKey(shortlistSortOption),
        let option = ShortlistSortOption(rawValue: shortlistSortOption) {
            sortOption = option
        }
        else {
            sortOption = ShortlistSortOption.YearDescending
        }

        return shortlists.sort {
            
            switch sortOption {
            case ShortlistSortOption.YearDescending:
                return $0.shortListYear > $1.shortListYear
            case ShortlistSortOption.YearAscending:
                return $0.shortListYear < $1.shortListYear
            case ShortlistSortOption.UpdatedDateDescending:
                return $0.updatedAt?.compare($1.updatedAt!) ==  NSComparisonResult.OrderedDescending
            case ShortlistSortOption.UpdatedDateAscending:
                return $0.updatedAt?.compare($1.updatedAt!) ==  NSComparisonResult.OrderedAscending
            }
        }
    }
}
