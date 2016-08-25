//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation
import Modelmatic

@objc (MDLAuthor)
class Author: ModelObject
{
    static let entityName = "Author"
    
    var externalID: NSNumber!
    var firstName: String?
    var lastName: String?
    var dateOfBirth: NSDate?
    var imageURL: UIImage?
    
    var books: [Book]?
}


extension Author
{
    var fullName: String {
        return (lastName == nil && firstName == nil ? "Unknown" :
            lastName == nil ? firstName! :
            firstName == nil ? lastName! :
            "\(lastName!), \(firstName!)")
    }
}