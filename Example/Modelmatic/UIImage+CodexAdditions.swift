//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

extension UIImage
{
    public class func image(named name: String, alternateName: String) -> UIImage?
    {
        let image = UIImage(named: name)
        return image ?? UIImage(named: alternateName)
    }
    
    public class func image(forBook book: Book) -> UIImage?
    {
        let imageName = book.title.stringByReplacingOccurrencesOfString(" ", withString: "")
        return UIImage.image(named: imageName, alternateName: "DefaultImage")
    }
    
    public class func image(forAuthor author: Author) -> UIImage?
    {
        guard let imageName = author.lastName else { return nil }
        return UIImage.image(named: imageName, alternateName: "NoImage")
    }
}

