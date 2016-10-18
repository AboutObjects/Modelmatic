//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation
import Modelmatic

@objc(MDLAuthor)
class Author: ModelObject
{
    static let entityName = "Author"
    
    var authorId: NSNumber?
    var firstName: String?
    var lastName: String?
    var dateOfBirth: Date?
    
    // Strong reference to children, to-many relationship
    var books: [Book]?
}


extension Author
{
    var fullName: String {
        switch (first: firstName, last: lastName) {
        case let (first?, last?): return "\(last), \(first)"
        case let (first?, _):     return first
        case let (_, last?):      return last
        default: return "Unknown"
        }
    }
}
