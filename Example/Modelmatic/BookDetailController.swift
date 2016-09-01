//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit
import Modelmatic

class BookDetailController: UITableViewController
{
    var book: Book!
    
    var save: ((book: Book) -> Void)?
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var authorImageView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        populateViews()
    }
    
    func populateViews() {
        bookImageView.image = UIImage.image(forBook: book)
        yearLabel.text = book.year
        tagsLabel.text = book.tags?.csvString
        ratingLabel.text = book.rating.description
        if let author = book.author {
            authorImageView.image = UIImage.image(forAuthor: author)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let navController = segue.destinationViewController as? UINavigationController,
            editController = navController.childViewControllers.first as? EditBookController else {
                return
        }
        editController.book = book
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch (section) {
        case 0: return "\(book.title)  \(book.favorite.description)"
        case 1: return book.author?.fullName
        default: return nil
        }
    }
}

// MARK: - Unwind Segues
extension BookDetailController
{
    @IBAction func doneEditingBook(segue: UIStoryboardSegue) {
        save?(book: book)
        tableView.reloadData()
    }
    
    @IBAction func cancelEditingBook(segue: UIStoryboardSegue) {
        /* do nothing */
    }
}

// MARK: - Formatting CSV
extension SequenceType where Self.Generator.Element == String
{
    var csvString: String? {
        guard let values = self as? NSArray else { return nil }
        return values.componentsJoinedByString(", ")
    }
}
