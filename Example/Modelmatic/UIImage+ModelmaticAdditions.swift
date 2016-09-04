//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import UIKit

extension UIImage
{
    class func image(named name: String, alternateName: String) -> UIImage?
    {
        let image = UIImage(named: name)
        return image ?? UIImage(named: alternateName)
    }
    
    class func image(forBook book: Book) -> UIImage?
    {
        let imageName = book.title.stringByReplacingOccurrencesOfString(" ", withString: "")
        return UIImage.image(named: imageName, alternateName: "DefaultImage")
    }
}

