//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//
import CoreData

let CSVTransformerName = "CSVTransformerName"
let DelimiterString = ","

@objc (CSVTransformer)
public class CSVTransformer: NSValueTransformer
{
    public override class func initialize() {
        guard self === CSVTransformer.self else { return }
        NSValueTransformer.setValueTransformer(CSVTransformer(), forName: CSVTransformerName)
    }
    
    override public class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        return true;
    }
    
    public override func transformedValue(value: AnyObject?) -> AnyObject? {
        guard let values = value as? NSArray else { return value }
        return values.componentsJoinedByString(DelimiterString)
    }
    
    public override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        guard let stringVal = value as? NSString else { return nil }
        return stringVal.componentsSeparatedByString(DelimiterString)
    }
}
