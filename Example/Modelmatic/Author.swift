//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation
import Modelmatic

@objc (Author)
public class Author: ModelObject
{
    public static let entityName = "Author"
    
    public var externalID: NSNumber!

    public var firstName: String?
    public var lastName: String?

    public var fullName: String {
        return (lastName == nil && firstName == nil ? "Unknown" :
            lastName == nil ? firstName! :
            firstName == nil ? lastName! :
            "\(lastName!), \(firstName!)")
    }
    
    public var dateOfBirth: NSDate?
    public var imageURL: UIImage?
    
    public var books: [Book]?
}