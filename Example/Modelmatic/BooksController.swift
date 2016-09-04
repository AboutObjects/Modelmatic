//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

class BooksController: UITableViewController
{
    @IBOutlet var dataSource: AuthorDataSource!
    
    override func viewDidLoad()
    {
        dataSource.fetch() { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        guard let indexPath = tableView.indexPathForSelectedRow,
            book = dataSource.objectStore.bookAtIndexPath(indexPath),
            navController = segue.destinationViewController as? UINavigationController,
            editController = navController.childViewControllers.first as? EditBookController else {
                return
        }
        
        editController.book = book
    }

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
//    {
//        guard let indexPath = tableView.indexPathForSelectedRow,
//            book = dataSource.objectStore.bookAtIndexPath(indexPath),
//            controller = segue.destinationViewController as? BookDetailController else {
//                return
//        }
//        
//        controller.book = book
//        controller.save = { book in self.dataSource.save() }
//    }
}

// MARK: - Action Methods
extension BooksController
{
    @IBAction func toggleStorageMode(sender: AnyObject)
    {
        dataSource.toggleStorageMode()
        dataSource.fetch(){ [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - Unwind Segues
extension BooksController
{
    @IBAction func doneEditingBook(segue: UIStoryboardSegue) {
        dataSource.save()
        tableView.reloadData()
    }
    
    @IBAction func cancelEditingBook(segue: UIStoryboardSegue) {
        /* do nothing */
    }
}


// MARK: - UITableViewDelegate Methods

extension BooksController
{
    override  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.oddRowColor() : UIColor.evenRowColor()
    }
}
