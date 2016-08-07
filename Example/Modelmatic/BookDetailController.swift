//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

public class BookDetailController: UITableViewController
{
    var book: Book!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        titleLabel.text = book.title
        yearLabel.text = book.year
        bookImageView.image = UIImage.image(forBook: book)
        
        if let author = book.author {
            firstNameLabel.text = author.firstName
            lastNameLabel.text = author.lastName
            authorImageView.image = UIImage.image(forAuthor: author)
        }
    }
}