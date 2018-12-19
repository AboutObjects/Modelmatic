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
    
    // Swift enums (e.g., Heart and Stars, below) can't
    // be directly handled via ObjC introspection, and can't be annotated `@objc`.
    // The ObjC runtime also cannot deal with Swift scalar types (e.g., Int, Double, etc.)
    // wrapped in Optionals, since Objective-C scalars can't be null.
    //
    // A workaround in these situations is to provide appropriately typed wrapper properties,
    // prefixed with `kvc_` (for example, `kvc_favorite`, of type `Bool`, `kvc_rating`,
    // of type `Int`, etc.).
    //
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

// MARK: - KVC compliance
// Custom handling for Swift enums, scalars wrapped in Optionals,
// and any unbridged Swift structs.
extension Book
{
    @objc var kvc_favorite: Bool {
        get { return favorite == .yes }
        set { favorite = newValue ? .yes : .no }
    }
    
    @objc var kvc_rating: Int {
        get { return rating.rawValue }
        set { rating = Stars(rawValue: newValue) ?? .zero }
    }
    
    @objc var kvc_retailPrice: Double {
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
