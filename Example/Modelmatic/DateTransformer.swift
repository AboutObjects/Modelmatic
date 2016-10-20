//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation

@objc (MDLDateTransformer)
class DateTransformer: ValueTransformer
{
    static let transformerName = NSValueTransformerName("Date")
    
    override class func transformedValueClass() -> AnyClass { return NSString.self }
    override class func allowsReverseTransformation() -> Bool { return true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let date = value as? Date else { return nil }
        return serializedDateFormatter.string(from: date)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let stringVal = value as? String else { return nil }
        return serializedDateFormatter.date(from: stringVal)
    }
}

private let serializedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()
