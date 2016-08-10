//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

public class BooksController: UITableViewController
{
    @IBOutlet var dataSource: AuthorDataSource!
    
    public override func viewDidLoad()
    {
        dataSource.fetch() { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        guard
            let indexPath = tableView.indexPathForSelectedRow,
            let book = dataSource.objectStore.bookAtIndexPath(indexPath),
            let controller = segue.destinationViewController as? BookDetailController else {
                return
        }
        
        controller.book = book
    }
}

extension BooksController
{
    @IBAction func toggleStorageMode(sender: AnyObject)
    {
        dataSource.toggleStorageMode()
        dataSource.fetch(){ [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // Unwind segue
    @IBAction func doneEditingBook(segue: UIStoryboardSegue)
    {
        dataSource.save()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate Methods

extension BooksController
{
    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.oddRowColor() : UIColor.evenRowColor()
    }
}
