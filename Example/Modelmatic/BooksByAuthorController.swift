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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
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
    @IBAction func toggleStorageMode(_ sender: AnyObject) {
        dataSource.toggleStorageMode()
        dataSource.fetch { [weak self] in self?.tableView.reloadData() }
    }
}

// MARK: - Unwind Segues
extension BooksByAuthorController
{
    @IBAction func doneEditingBook(_ segue: UIStoryboardSegue) {
        dataSource.save()
        tableView.reloadData()
    }
    @IBAction func doneAddingBook(_ segue: UIStoryboardSegue) {
        dataSource.save()
        tableView.reloadData()
    }
    @IBAction func cancelEditingBook(_ segue: UIStoryboardSegue) { }
    @IBAction func cancelAddingBook(_ segue: UIStoryboardSegue) { }
}


// MARK: - UITableViewDelegate Methods

extension BooksByAuthorController
{
    override  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = (indexPath as NSIndexPath).row % 2 == 0 ? UIColor.oddRowColor : UIColor.evenRowColor
    }
}

// MARK: - UIStoryboardSegue
extension UIStoryboardSegue
{
    var targetViewController: UIViewController? {
        if let navController = destination as? UINavigationController { return navController.childViewControllers.first }
        return destination
    }
}
