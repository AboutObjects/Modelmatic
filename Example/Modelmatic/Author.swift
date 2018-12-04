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
    
    @objc var authorId: NSNumber?
    @objc var firstName: String?
    @objc var lastName: String?
    @objc var dateOfBirth: Date?
    
    // Strong reference to children, to-many relationship
    @objc var books: [Book]?
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
