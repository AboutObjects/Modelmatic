//
// Copyright (C) 2016 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit
import CoreData

class AddBookController: UITableViewController
{
    var dataSource: AuthorDataSource!
    
    @IBOutlet weak var authorPicker: UIPickerView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    var authors: [Author]! { return dataSource.authors }
    var author: Author { return authors[authorPicker.selectedRow(inComponent: 0)] }
    lazy var book: Book = Book(dictionary: [:], entity: self.dataSource.objectStore.bookEntity)
    
    func populateBook() {
        book.title = titleField.text
        book.year = yearField.text
        book.retailPrice = Double(priceField.text ?? "0")
    }
    
    func addBookToAuthor() {
        do {
            try author.add(modelObject: book, forKey: "books")
        } catch {
            fatalError("Unable to add book to author \(author)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "Done" {
            populateBook()
            addBookToAuthor()
            dataSource.save()
        }
    }
}


// MARK: - UIPickerViewDataSource
extension AddBookController: UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return authors.count }
}

// MARK: - UIPickerViewDelegate
extension AddBookController: UIPickerViewDelegate
{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return authors[row].fullName
    }
}
