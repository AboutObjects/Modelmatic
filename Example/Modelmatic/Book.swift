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
    
    var externalID: NSNumber?
    var title: String!
    var year: String?
    var tags: [String]?
    var favorite: Heart = .no
    var rating: Stars = .zero
    
    // Reference to child object in one-to-one relationship
    var pricing: Pricing?
    
    // Reference to parent object in one-to-many relationship
    // IMPORTANT: Use weak reference when modeling inverse relationship.
    weak var author: Author?
    
    override var description: String {
        return "\(super.description) title: \(title); year: \(year), tags: \(tags), externalID: \(externalID)"
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
}
