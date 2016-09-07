//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

class BooksByAuthorController: UITableViewController
{
    @IBOutlet var dataSource: AuthorDataSource!
    
    override func viewDidLoad() {
        dataSource.fetch { [weak self] in self?.tableView.reloadData() }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        switch segue.identifier ?? "" {
        case "Edit":
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            (segue.targetViewController as? EditBookController)?.book = dataSource.objectStore.bookAtIndexPath(indexPath)
        case "Add":
            (segue.targetViewController as? AddBookController)?.dataSource = dataSource
        default: break
        }
    }
}

// MARK: - Action Methods
extension BooksByAuthorController
{
    @IBAction func toggleStorageMode(sender: AnyObject) {
        dataSource.toggleStorageMode()
        dataSource.fetch(){ [weak self] in self?.tableView.reloadData() }
    }
}

// MARK: - Unwind Segues
extension BooksByAuthorController
{
    @IBAction func doneEditingBook(segue: UIStoryboardSegue) {
        dataSource.save()
        tableView.reloadData()
    }
    @IBAction func doneAddingBook(segue: UIStoryboardSegue) {
        dataSource.save()
        tableView.reloadData()
    }
    @IBAction func cancelEditingBook(segue: UIStoryboardSegue) { }
    @IBAction func cancelAddingBook(segue: UIStoryboardSegue) { }
}


// MARK: - UITableViewDelegate Methods

extension BooksByAuthorController
{
    override  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.oddRowColor() : UIColor.evenRowColor()
    }
}

// MARK: - UIStoryboardSegue
extension UIStoryboardSegue
{
    var targetViewController: UIViewController? {
        if let navController = destinationViewController as? UINavigationController { return navController.childViewControllers.first }
        return destinationViewController
    }
}
