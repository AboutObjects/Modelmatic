//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit
import Modelmatic

let cellId = "Book"

class AuthorDataSource: NSObject
{
    @IBOutlet var objectStore: AuthorObjectStore!
    
    var authors: [Author]? { return objectStore.authors }
    
    func toggleStorageMode() { objectStore.toggleStorageMode() }
    func fetch(completion: () -> Void) { objectStore.fetch(completion) }
    func save() { objectStore.save() }
}

extension AuthorDataSource: UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return objectStore.numberOfSections()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return objectStore.titleForSection(section)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectStore.numberOfRows(inSection: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? BookCell else {
            fatalError("Unable to dequeue a cell with identifier \(cellId)")
        }
        self.populateCell(cell, atIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete {
            objectStore.removeBookAtIndexPath(indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            save()
        }
    }
}

// MARK: - Populating Cells
extension AuthorDataSource
{
    func configureCell(cell: BookCell, atIndexPath indexPath: NSIndexPath) {
        guard let book = objectStore.bookAtIndexPath(indexPath) else { return }
        cell.ratingLabel.alpha = book.rating == .zero ? 0.3 : 1
        cell.favoriteLabel.transform = book.favorite.boolValue ? CGAffineTransformMakeScale(1.2, 1.2) : CGAffineTransformIdentity
    }
    
    func populateCell(cell: BookCell, atIndexPath indexPath: NSIndexPath) {
        guard let book = objectStore.bookAtIndexPath(indexPath) else { return }
        cell.titleLabel.text = book.title
        cell.priceLabel.text = priceFormatter.stringFromNumber(NSNumber(double: book.retailPrice ?? 0))
        cell.ratingLabel.text = book.rating.description
        cell.favoriteLabel.text = book.favorite.description
    }
}

// MARK: - Enums
enum Heart: Int, CustomStringConvertible {
    case yes, no
    init(isFavorite: Bool?) {
        self = (isFavorite != nil && isFavorite!) ? .yes : .no
    }
    var boolValue: Bool { return self == .yes }
    var description: String { return self == .yes ? "♥︎" : "♡" }
    mutating func toggle() {
        self = self == .yes ? .no : .yes
    }
}

enum Stars: Int, CustomStringConvertible {
    case zero, one, two, three, four, five
    init(rating: Int?) {
        self = Stars(rawValue: rating ?? 0) ?? zero
    }
    var description: String {
        switch self {
        case zero:  return "☆☆☆☆☆"
        case one:   return "★☆☆☆☆"
        case two:   return "★★☆☆☆"
        case three: return "★★★☆☆"
        case four:  return "★★★★☆"
        case five:  return "★★★★★"
        }
    }
}

// MARK: - Formatting Prices
let priceFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    return formatter
}()
