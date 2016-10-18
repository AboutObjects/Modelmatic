//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

class EditBookController: UITableViewController
{
    var book: Book!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var tagsLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingStepper: UIStepper!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateViews();
    }
    
    func populateViews() {
        titleField.text = book.title
        yearField.text = book.year
        priceField.text = String(format: "%.2f", book.retailPrice ?? 0.0)
        tagsLabel.text = book.tags?.csvString
        favoriteButton.setTitle(book.favorite.description, for: UIControlState())
        ratingLabel.text = book.rating.description
        ratingStepper.value = Double(book.rating.rawValue)
    }
    
    func updateBook() {
        book.title = titleField.text
        book.year = yearField.text
        book.retailPrice = Double(priceField.text ?? "0.0")
    }
    
    func toggleFavorite() {
        book.favorite.toggle()
        favoriteButton.setTitle(book.favorite.description, for: UIControlState())
    }
}

// MARK: - Action Methods
extension EditBookController
{
    @IBAction func rate(_ sender: UIStepper) {
        book.rating = Stars(rawValue: Int(sender.value)) ?? .zero
        ratingLabel.text = book.rating.description
    }
    
    @IBAction func favorite(_ sender: UIButton) {
        toggleFavorite()
    }
}

// MARK: - Performing Segues
extension EditBookController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "Done": updateBook()
        case "EditTags": prepareToEditTags(segue)
        default: break
        }
    }
    
    func prepareToEditTags(_ segue: UIStoryboardSegue) {
        if let controller = segue.destination as? TagsController { controller.book = book }
    }
}

// MARK: - UITableViewDelegate
extension EditBookController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            toggleFavorite()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? book.author?.fullName ?? "" : nil
    }
}

// MARK: - UITextFieldDelegate
extension EditBookController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Formatting CSV
extension Sequence where Self.Iterator.Element == String
{
    var csvString: String? {
        guard let values = self as? NSArray else { return nil }
        return values.componentsJoined(by: ", ")
    }
}
