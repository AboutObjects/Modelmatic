//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation
import Modelmatic

@objc(MDLBook)
class Book: ModelObject
{
    static let entityName = "Book"
    
    @objc var bookId: NSNumber?
    @objc var title: String!
    @objc var year: String?
    @objc var tags: [String]?
    
    // Broken in Swift 4 with `Swift 3 @objc inference` disabled
    var favorite: Heart = .no
    var rating: Stars = .zero
    var retailPrice: Double?
    
    // Strong reference to child object, one-to-one relationship
    @objc var pricing: Pricing?
    
    // Weak reference to parent object, inverse of one-to-many relationship
    @objc weak var author: Author?
    
    override var description: String {
        return "\(super.description) title: \(String(describing: title)); year: \(String(describing: year)), tags: \(String(describing: tags)), bookId: \(String(describing: bookId))"
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

// MARK: - Keys
extension Book
{
    enum Keys: String {
        case bookId, title, year, tags, favorite, rating, retailPrice, pricing, author
    }
}
