//
// Copyright (C) 2016 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import CoreData

public typealias JsonDictionary = [String: Any]

extension NSPropertyDescription
{
    public var keyPath: String {
        return userInfo?["jsonKeyPath"] as? String ?? name
    }
}

public extension Array where Element: ModelObject
{
    public var dictionaryRepresentation: [JsonDictionary] {
        return map { $0.encodedValues(parent: nil) }
    }
}

public extension Data
{
    public func deserializeJson() throws -> Any
    {
        do {
            return try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions(rawValue: 0))
        }
        catch let error as NSError {
            print("Unable to deserialize JSON due to error: \(error)")
            throw error
        }
    }
}

public extension NSDictionary
{
    public func serializeAsJson(pretty: Bool) throws -> Data
    {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: pretty ? .prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0))
        }
        catch let error as NSError {
            print("Unable to deserialize as JSON due to error: \(error)")
            throw error
        }
    }
    
    public class func dictionary(contentsOf url: URL) -> NSDictionary?
    {
        guard let data = try? Data(contentsOf: url),
            let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) else {
                return nil
        }
        return dict as? NSDictionary
    }
}

public extension String
{
    public var keyPathComponents: [String] {
        return (self as NSString).components(separatedBy: ".")
    }
}
