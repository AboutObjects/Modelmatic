//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

public class EditBookController: UITableViewController
{
    public var book: Book!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var tagsField: UITextField!
    
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingStepper: UIStepper!
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        titleField.text = book.title
        yearField.text = book.year
        tagsField.text = book.transformedTags
        
        heartLabel.text = FavoriteSymbol.stringValue(book.favorite)
        ratingLabel.text = Rating.stringValue(book.rating)
        ratingStepper.value = Double(book.rating ?? 0)
        
        
        titleField.becomeFirstResponder()
    }
    
    @IBAction func rate(sender: UIStepper)
    {
        book.rating = Int(sender.value)
        ratingLabel.text = Rating.stringValue(book.rating)
    }
    
    func toggleFavorite()
    {
        book.favorite = book.favorite == nil || book.favorite == false ? true : false
        heartLabel.text = FavoriteSymbol.stringValue(book.favorite)
    }
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 0 && indexPath.row == 0 {
            toggleFavorite()
        }
    }
    
    func updateBook()
    {
        book.title = titleField.text
        book.year = yearField.text
        book.transformedTags = tagsField.text
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "Done" {
            updateBook()
        }
    }
}