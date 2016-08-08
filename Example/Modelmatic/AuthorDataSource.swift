//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

let CellID = "Book"

public enum FavoriteSymbol: String {
    case FilledHeart = "♥️"
    case BlankHeart = "♡"
    
    static func stringValue(bool: Bool?) -> String {
        return bool != nil && bool! == true ? FilledHeart.rawValue : BlankHeart.rawValue
    }
}

public enum Rating: String {
    case Zero  = "☆☆☆☆☆"
    case One   = "★☆☆☆☆"
    case Two   = "★★☆☆☆"
    case Three = "★★★☆☆"
    case Four  = "★★★★☆"
    case Five  = "★★★★★"
    
    static func stringValue(int: Int?) -> String {
        var val: Rating
        switch (int ?? 0) {
        case 0:  val = Zero
        case 1:  val = One
        case 2:  val = Two
        case 3:  val = Three
        case 4:  val = Four
        case 5:  val = Five
        default: val = int < 0 ? Zero : Five
        }
        return val.rawValue
    }
}

public class AuthorDataSource: NSObject
{
    @IBOutlet var objectStore: AuthorObjectStore!
    
    public func save() {
        objectStore.save()
    }
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
        let favString = "  " + FavoriteSymbol.stringValue(book.favorite)
        cell.titleLabel.text = book.title + favString
        cell.infoLabel.text = String(format: "%@ %@", book.year ?? "" , book.author?.fullName ?? "")
        cell.bookImageView.image = UIImage.image(forBook: book)
    }
}