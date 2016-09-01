//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

let CellID = "Book"

enum Heart: Int, CustomStringConvertible {
    case yes, no
    init(isFavorite: Bool?) {
        self = (isFavorite != nil && isFavorite!) ? .yes : .no
    }
    var boolValue: Bool { return self == .yes }
    var description: String { return self == .yes ? "♥️" : "♡" }
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

class AuthorDataSource: NSObject
{
    @IBOutlet var objectStore: AuthorObjectStore!
    
    func toggleStorageMode() {
        objectStore.toggleStorageMode()
    }
    func fetch(completion: () -> Void) {
        objectStore.fetch(completion)
    }
    func save() {
        objectStore.save()
    }
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
        guard let cell = tableView.dequeueReusableCellWithIdentifier(CellID) as? BookCell else {
            NSLog("WARNING: Unable to dequeue a cell with identifier \(CellID)")
            abort()
        }
        self.populateCell(cell, atIndexPath: indexPath)
        return cell
    }
}

// MARK: - Populating Cells
extension AuthorDataSource
{
    func populateCell(cell: BookCell, atIndexPath indexPath: NSIndexPath)
    {
        guard let book = objectStore.bookAtIndexPath(indexPath) else { return }
        cell.titleLabel.text = "\(book.title)  \(book.favorite.description)"
        cell.infoLabel.text = String(format: "%@ %@", book.year ?? "" , book.author?.fullName ?? "")
        cell.bookImageView.image = UIImage.image(forBook: book)
    }
}