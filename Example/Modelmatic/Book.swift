//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation
import Modelmatic

@objc (MDLBook)
class Book: ModelObject
{
    static let entityName = "Book"
    
    var bookId: NSNumber?
    var title: String!
    var year: String?
    var tags: [String]?
    var favorite: Heart = .no
    var rating: Stars = .zero
    var retailPrice: Double?
    
    // Strong reference to child object, one-to-one relationship
    var pricing: Pricing?
    
    // Weak reference to parent object, inverse of one-to-many relationship
    weak var author: Author?
    
    override var description: String {
        return "\(super.description) title: \(title); year: \(year), tags: \(tags), bookId: \(bookId)"
    }
}


// MARK: - Wrapping and Unwrapping Optional Structs

extension Book
{
    var kvc_favorite: Bool {
        get { return favorite == .yes }
        set { favorite = newValue ? .yes : .no }
    }
    
    var kvc_rating: Int {
        get { return rating.rawValue }
        set { rating = Stars(rawValue: newValue) ?? .zero }
    }
    
    var kvc_retailPrice: Double {
        get { return retailPrice ?? 0.0 }
        set { retailPrice = Optional(newValue) }
    }
}
