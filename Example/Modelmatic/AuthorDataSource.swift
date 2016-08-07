//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

let CellID = "Book"

public class AuthorDataSource: NSObject
{
    @IBOutlet var objectStore: AuthorObjectStore!
}

extension AuthorDataSource: UITableViewDataSource
{
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return objectStore.numberOfSections()
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return objectStore.titleForSection(section)
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectStore.numberOfRows(inSection: section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(CellID) as? BookCell else {
            NSLog("WARNING: Unable to dequeue a cell with identifier \(CellID)")
            abort()
        }
        self.populateCell(cell, atIndexPath: indexPath)
        return cell
    }
}

// MARK: - Populating Cells
public extension AuthorDataSource
{
    public func populateCell(cell: BookCell, atIndexPath indexPath: NSIndexPath)
    {
        guard let book = objectStore.bookAtIndexPath(indexPath) else { return }
        cell.titleLabel.text = book.title
        cell.infoLabel.text = String(format: "%@ %@", book.year ?? "" , book.author?.fullName ?? "")
        cell.bookImageView.image = UIImage.image(forBook: book)
    }
}