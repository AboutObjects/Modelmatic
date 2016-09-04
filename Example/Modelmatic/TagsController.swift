//
// Copyright (C) 2016 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

class TagsController: UITableViewController
{
    var book: Book!
    lazy var tags: [String] = self.book.tags ?? [String]()
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().sendAction(#selector(resignFirstResponder), to: nil, from: nil, forEvent: nil)
        book.tags = tags.filter { $0 != "" }
    }
}

// MARK: - Action Methods
extension TagsController
{
    @IBAction func addTag(sender: AnyObject) {
        let lastIndexPath = NSIndexPath(forRow: tags.count, inSection: 0)
        tags.append("")
        tableView.insertRowsAtIndexPaths([lastIndexPath], withRowAnimation: .Automatic)
        tableView.selectRowAtIndexPath(lastIndexPath, animated: true, scrollPosition: .Middle)
        
        if let cell = tableView.cellForRowAtIndexPath(lastIndexPath) as? EditableCell {
            cell.textField.becomeFirstResponder()
        }
    }

    @IBAction func modifyTag(textField: UITextField) {
        guard let indexPath = tableView.indexPathForSelectedRow, cell = tableView.cellForRowAtIndexPath(indexPath) as? EditableCell else {
            return
        }
        tags[indexPath.row] = cell.textField.text ?? ""
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension TagsController
{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? EditableCell else { return }
        cell.textField.text = tags[indexPath.row] ?? ""
    }
}

// MARK: - UITableViewDataSource
extension TagsController
{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count ?? 0;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("TagCell") as? EditableCell else {
            fatalError("Unable to dequeue instance of EditableCell. Make sure identifier is set in storyboard.")
        }
        cell.textField.text = tags[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        guard case .Delete = editingStyle else { return }
        tags.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
}
