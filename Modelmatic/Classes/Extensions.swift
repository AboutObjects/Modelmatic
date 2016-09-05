//
// Copyright (C) 2016 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import CoreData

public typealias JsonDictionary = [String: AnyObject]

extension NSPropertyDescription
{
    public var keyPath: String {
        return userInfo?["jsonKeyPath"] as? String ?? name
    }
}

public extension Array where Element: ModelObject
{
    public var dictionaryRepresentation: [JsonDictionary] {
        return self.map { $0.encodedValues(parent: nil) }
    }
}

public extension NSData
{
    public func deserializeJson() throws -> AnyObject
    {
        do {
            return try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions(rawValue: 0))
        }
        catch let error as NSError {
            print("Unable to deserialize JSON due to error: \(error)")
            throw error
        }
    }
}

public extension NSDictionary
{
    public func serializeAsJson(pretty pretty: Bool) throws -> NSData
    {
        do {
            return try NSJSONSerialization.dataWithJSONObject(self, options: pretty ? .PrettyPrinted : NSJSONWritingOptions(rawValue: 0))
        }
        catch let error as NSError {
            print("Unable to deserialize as JSON due to error: \(error)")
            throw error
        }
    }
    
    public class func dictionary(contentsOf url: NSURL) -> NSDictionary?
    {
        guard let data = NSData(contentsOfURL: url),
            dict = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) else {
                return nil
        }
        return dict as? NSDictionary
    }
}

public extension String
{
    public var keyPathComponents: [String] {
        return (self as NSString).componentsSeparatedByString(".")
    }
}