//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

let CellID = "Book"

enum FavoriteSymbol: String {
    case filledHeart = "♥️"
    case blankHeart = "♡"
    
    static func stringValue(bool: Bool?) -> String {
        return bool != nil && bool! == true ? filledHeart.rawValue : blankHeart.rawValue
    }
}

enum Rating: String {
    case zero  = "☆☆☆☆☆"
    case one   = "★☆☆☆☆"
    case two   = "★★☆☆☆"
    case three = "★★★☆☆"
    case four  = "★★★★☆"
    case five  = "★★★★★"
    
    static func stringValue(int: Int?) -> String {
        var val: Rating
        switch (int ?? 0) {
        case 0:  val = zero
        case 1:  val = one
        case 2:  val = two
        case 3:  val = three
        case 4:  val = four
        case 5:  val = five
        default: val = int < 0 ? zero : five
        }
        return val.rawValue
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
        let favString = "  " + FavoriteSymbol.stringValue(book.favorite)
        cell.titleLabel.text = book.title + favString
        cell.infoLabel.text = String(format: "%@ %@", book.year ?? "" , book.author?.fullName ?? "")
        cell.bookImageView.image = UIImage.image(forBook: book)
    }
}