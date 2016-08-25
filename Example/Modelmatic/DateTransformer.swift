//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation

@objc (MDLDateTransformer)
class DateTransformer: NSValueTransformer
{
    static let transformerName = "Date"
    
    override class func transformedValueClass() -> AnyClass { return NSString.self }
    override class func allowsReverseTransformation() -> Bool { return true }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        guard let date = value as? NSDate else { return nil }
        return serializedDateFormatter.stringFromDate(date)
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        guard let stringVal = value as? String else { return nil }
        return serializedDateFormatter.dateFromString(stringVal)
    }
}

private let serializedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()
