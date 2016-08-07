//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation
import CoreData

let ModelName = "Authors"
let FileName = "Authors"

extension Dictionary
{
    static func byLoading(fileName: String) -> [String: AnyObject]?
    {
        return self.byLoadingJSON(fileName) ?? self.byLoadingPropertyList(fileName)
    }

    static func byLoadingJSON(fileName: String) -> [String: AnyObject]?
    {
        if let dict = self.byLoadingJSON(NSURL.documentDirectoryURL(forFileName: fileName, type: "plist")) {
            return dict
        }
        return self.byLoadingJSON(NSURL.bundleDirectoryURL(forFileName: fileName, type: "plist"))
    }

    static func byLoadingJSON(fileUrl: NSURL?) -> [String: AnyObject]?
    {
        guard let url = fileUrl, data = NSData(contentsOfURL: url),
        dict = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String: AnyObject] else {
            return nil
        }
        return dict
    }
    
    static func byLoadingPropertyList(fileName: String) -> [String: AnyObject]?
    {
        if let dict = self.byLoadingPropertyList(NSURL.documentDirectoryURL(forFileName: fileName, type: "plist")) {
            return dict
        }
        return self.byLoadingPropertyList(NSURL.bundleDirectoryURL(forFileName: fileName, type: "plist"))
    }
    
    static func byLoadingPropertyList(fileUrl: NSURL?) -> [String: AnyObject]?
    {
        guard let url = fileUrl else { return nil }
        return NSDictionary(contentsOfURL: url) as? [String: AnyObject]
    }
    
    static func hello() -> String {
        return "Hello"
    }
}

extension NSURL
{
    class func documentDirectoryURL(forFileName fileName: String, type: String) -> NSURL?
    {
        let URLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return URLs.first?.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension(type)
    }
    
    class func bundleDirectoryURL(forFileName fileName: String, type: String) -> NSURL?
    {
        return NSBundle(forClass: AuthorObjectStore.self).URLForResource(fileName, withExtension: type)
    }
}

typealias JSONDictionary = [String: AnyObject]

public class AuthorObjectStore: NSObject
{
    let model: NSManagedObjectModel!
    let entity: NSEntityDescription!
    
    var serializedAuthors: [[String: AnyObject]]!
    var authors: [Author]!
    
    required override public init()
    {
        let modelURL = NSBundle(forClass: AuthorObjectStore.self).URLForResource(ModelName, withExtension: "momd")
        model = NSManagedObjectModel(contentsOfURL: modelURL!) // Crash here if model URL is invalid.
        
        entity = model.entitiesByName[Author.entityName]
        
        guard let dict = JSONDictionary.byLoading(FileName) else {
            fatalError("Unable to load authors from file named \(FileName)")
        }
        
        serializedAuthors = dict["authors"] as? [[String: AnyObject]]
        
        super.init()
        
        authors = serializedAuthors.map {
            Author(dictionary: $0, entity: self.entity)
        }
    }
}


// MARK: - DataSource Support

public extension AuthorObjectStore
{
    public func titleForSection(section: NSInteger) -> String
    {
        return authors[section].fullName
    }
    
    public func numberOfSections() -> NSInteger
    {
        return authors.count
    }
    
    public func numberOfRows(inSection section: NSInteger) -> NSInteger
    {
        let books = authors[section].books
        return books == nil ? 0 : books!.count
    }
    
    public func bookAtIndexPath(indexPath: NSIndexPath) -> Book?
    {
        let books = authors[indexPath.section].books
        return books == nil ? nil : books![indexPath.row]
    }
}