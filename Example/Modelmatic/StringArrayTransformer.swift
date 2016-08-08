//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//
import CoreData

private let delimiterString = ","

@objc (MDLStringArrayTransformer)
public class StringArrayTransformer: NSValueTransformer
{
    public static let transformerName = "StringArray"

    override public class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        return true;
    }
    
    public override func transformedValue(value: AnyObject?) -> AnyObject? {
        guard let values = value as? NSArray else { return value }
        return values.componentsJoinedByString(delimiterString)
    }
    
    public override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        guard let stringVal = value as? String else { return nil }
        return stringVal.componentsSeparatedByString(delimiterString)
    }
}
