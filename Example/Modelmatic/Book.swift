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
    var favorite: Bool?
    var rating: Int?
    
    // Reference to child object in one-to-one relationship
    var pricing: Pricing?
    
    // Reference to parent object in one-to-many relationship
    // IMPORTANT: Use weak reference when modeling inverse relationship.
    weak var author: Author?
    
    override  var description: String {
        return "\(super.description) title: \(title); year: \(year), tags: \(tags), externalID: \(externalID)"
    }
}


// MARK: - Wrapping and Unwrapping Optional Structs

extension Book
{
    var kvc_favorite: Bool {
        get { return favorite ?? false }
        set { favorite = Optional(newValue) }
    }
    
    var kvc_rating: Int {
        get { return rating ?? 0 }
        set { rating = Optional(newValue) }
    }
}


// MARK: - Transforming Values

private let tagsTransformer = StringArrayTransformer()

extension Book
{
    var transformedTags: String? {
        get { return tagsTransformer.transformedValue(tags) as? String }
        set { self.tags = tagsTransformer.reverseTransformedValue(newValue) as? [String] }
    }
}
