//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

public class BooksController: UITableViewController
{
    @IBOutlet var dataSource: AuthorDataSource!
    
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