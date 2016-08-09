//
// Copyright (C) 2016 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import CoreData

public typealias JsonDictionary = [String: AnyObject]

extension NSPropertyDescription
{
    public var externalKeyPath: String {
        return userInfo?["externalKeyPath"] as? String ?? name
    }
}

public extension Array where Element : ModelObject
{
    public var dictionaryRepresentation: [JsonDictionary] {
        return self.map { $0.dictionaryRepresentation }
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
    public func serializeAsJson() throws -> NSData
    {
        do {
            return try NSJSONSerialization.dataWithJSONObject(self, options: NSJSONWritingOptions(rawValue: 0))
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