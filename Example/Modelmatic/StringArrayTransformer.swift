//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//
import Foundation

private let delimiterString = ","

@objc (MDLStringArrayTransformer)
class StringArrayTransformer: ValueTransformer
{
    static let transformerName = NSValueTransformerName("StringArray")
    
    override class func transformedValueClass() -> AnyClass { return NSString.self }
    override class func allowsReverseTransformation() -> Bool { return true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let values = value as? NSArray else { return value }
        return values.componentsJoined(by: delimiterString)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let stringVal = value as? String else { return nil }
        return stringVal.components(separatedBy: delimiterString)
    }
}
