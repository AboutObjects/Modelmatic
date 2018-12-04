//
// Copyright (C) 2016 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

class TagsController: UITableViewController
{
    var book: Book!
    lazy var tags: [String] = self.book.tags ?? [String]()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        book.tags = tags.filter { $0 != "" }
    }
}

// MARK: - Action Methods
extension TagsController
{
    @IBAction func addTag(_ sender: AnyObject) {
        let lastIndexPath = IndexPath(row: tags.count, section: 0)
        tags.append("")
        tableView.insertRows(at: [lastIndexPath], with: .automatic)
        tableView.selectRow(at: lastIndexPath, animated: true, scrollPosition: .middle)
        
        if let cell = tableView.cellForRow(at: lastIndexPath) as? EditableCell {
            cell.textField.becomeFirstResponder()
        }
    }

    @IBAction func modifyTag(_ textField: UITextField) {
        guard let indexPath = tableView.indexPathForSelectedRow, let cell = tableView.cellForRow(at: indexPath) as? EditableCell else {
            return
        }
        tags[indexPath.row] = cell.textField.text ?? ""
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension TagsController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? EditableCell else { return }
        cell.textField.text = tags[indexPath.row]
    }
}

// MARK: - UITableViewDataSource
extension TagsController
{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell") as? EditableCell else {
            fatalError("Unable to dequeue instance of EditableCell. Make sure identifier is set in storyboard.")
        }
        cell.textField.text = tags[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard case .delete = editingStyle else { return }
        tags.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
