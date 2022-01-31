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

public class SLSortOptionsVC: SLBaseVC, UITableViewDelegate, UITableViewDataSource  {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.black
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = self.view.bounds
        
        return tableView
    }()
    
    lazy var selectedIndexPath: IndexPath = {
        guard let storeSortOption = UserDefaults.standard.string(forKey: shortlistSortOption) else { return IndexPath(row: 0, section: 0) }
        guard let row =  ShortlistSortOption(rawValue: storeSortOption) else { return  IndexPath(row: 0, section: 0) }

        return IndexPath(row: row.hashValue, section: 0)
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sorting Options"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSort))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(applySort))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: sortCellIdentifier)
        view.addSubview(tableView)
    }
    
    @objc func cancelSort() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func applySort() {
        dismiss(animated: true) {
            let defaults = UserDefaults.standard
            defaults.set(ShortlistSortOption.allValues[self.selectedIndexPath.row].rawValue, forKey: shortlistSortOption)
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ShortlistSortOption.allValues.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:sortCellIdentifier, for: indexPath)
        cell.contentView.backgroundColor = UIColor.black
        cell.backgroundColor = UIColor.black
        cell.textLabel?.font = SLStyle.polarisFont(withSize: 14.0)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = ShortlistSortOption.allValues[indexPath.row].rawValue
        cell.selectionStyle = .none
        cell.tintColor = UIColor.sl_Red()
        
        if indexPath.row == selectedIndexPath.row {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.sl_Red()
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            return
        }
        
        tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
        tableView.cellForRow(at: selectedIndexPath)?.textLabel?.textColor = UIColor.white
        
        selectedIndexPath = indexPath
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.cellForRow(at: selectedIndexPath)?.textLabel?.textColor = UIColor.sl_Red()
    }
    
    @objc static func orderShortListForDisplay(shortlists: [SLShortlist]) -> [SLShortlist] {
        var sortOption: ShortlistSortOption
        
        let prefs = UserDefaults.standard

        if let shortlistSortOption = prefs.string(forKey: shortlistSortOption),
        let option = ShortlistSortOption(rawValue: shortlistSortOption) {
            sortOption = option
        }
        else {
            sortOption = ShortlistSortOption.YearDescending
        }

        return shortlists.sorted {
            
            switch sortOption {
            case ShortlistSortOption.YearDescending:
                return $0.shortListYear > $1.shortListYear
            case ShortlistSortOption.YearAscending:
                return $0.shortListYear < $1.shortListYear
            case ShortlistSortOption.UpdatedDateDescending:
                return $0.updatedAt?.compare($1.updatedAt!) ==  ComparisonResult.orderedDescending
            case ShortlistSortOption.UpdatedDateAscending:
                return $0.updatedAt?.compare($1.updatedAt!) ==  ComparisonResult.orderedAscending
            }
        }
    }
}
