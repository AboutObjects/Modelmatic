//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

class EditBookController: UITableViewController
{
    var book: Book!
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var tagsLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingStepper: UIStepper!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        populateViews();
    }
    
    func populateViews() {
        titleField.text = book.title
        yearField.text = book.year
        tagsLabel.text = book.tags?.csvString
        bookImageView.image = UIImage.image(forBook: book)
        favoriteButton.setTitle(book.favorite.description, forState: .Normal)
        ratingLabel.text = book.rating.description
        ratingStepper.value = Double(book.rating.rawValue ?? 0)
    }
    
    func toggleFavorite() {
        book.favorite.toggle()
        favoriteButton.setTitle(book.favorite.description, forState: .Normal)
    }
}

// MARK: - Action Methods
extension EditBookController
{
    @IBAction func rate(sender: UIStepper) {
        book.rating = Stars(rawValue: Int(sender.value)) ?? .zero
        ratingLabel.text = book.rating.description
    }
    
    @IBAction func favorite(sender: UIButton) {
        toggleFavorite()
    }
}

// MARK: - Performing Segues
extension EditBookController
{
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier ?? "" {
        case "Done": updateBook()
        case "EditTags": prepareToEditTags(segue)
        default: break
        }
    }
    
    func prepareToEditTags(segue: UIStoryboardSegue) {
        if let controller = segue.destinationViewController as? TagsController { controller.book = book }
    }
    
    func updateBook() {
        book.title = titleField.text
        book.year = yearField.text
    }
}

// MARK: - UITableViewDelegate
extension EditBookController
{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            toggleFavorite()
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? book.author?.fullName ?? "" : nil
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
