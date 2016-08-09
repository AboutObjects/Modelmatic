//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation
import CoreData
import Modelmatic

let ModelName = "Authors"
let FileName = "Authors"

extension NSDictionary
{
    public class func dictionary(contentsOfPropertyListFile fileName: String) -> NSDictionary?
    {
        if  let URL = NSURL.documentDirectoryURL(forFileName: fileName, type: "plist"),
            let dict = NSDictionary(contentsOfURL: URL) {
            return dict
        }
        
        guard let URL = NSURL.bundleDirectoryURL(forFileName: fileName, type: "plist") else { return nil }
        return NSDictionary(contentsOfURL: URL)
    }
    
    public class func dictionary(contentsOfJSONFile fileName: String) -> NSDictionary?
    {
        if let url = NSURL.documentDirectoryURL(forFileName: fileName, type: "json"),
            dict = NSDictionary.dictionary(contentsOf: url) {
            return dict
        }
        
        guard let url = NSURL.bundleDirectoryURL(forFileName: fileName, type: "json") else { return nil }
        return NSDictionary.dictionary(contentsOf: url)
    }
}

extension NSURL
{
    public class func documentDirectoryURL(forFileName fileName: String, type: String) -> NSURL?
    {
        let URLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return URLs.first?.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension(type)
    }
    
    public class func bundleDirectoryURL(forFileName fileName: String, type: String) -> NSURL?
    {
        return NSBundle(forClass: AuthorObjectStore.self).URLForResource(fileName, withExtension: type)
    }
}

public class AuthorObjectStore: NSObject
{
    let model: NSManagedObjectModel!
    let entity: NSEntityDescription!
    
    var version: NSNumber
    var authors: [Author]?
    
    required override public init()
    {
        let modelURL = NSBundle(forClass: AuthorObjectStore.self).URLForResource(ModelName, withExtension: "momd")
        model = NSManagedObjectModel(contentsOfURL: modelURL!) // Crash here if model URL is invalid.
        entity = model.entitiesByName[Author.entityName]
        
        // let dict = NSDictionary.dictionary(contentsOfPropertyListFile: FileName)
        let dict = NSDictionary.dictionary(contentsOfJSONFile: FileName)
        
        version = dict?["version"] as? NSNumber ?? NSNumber(int: 0)
        super.init()
        
        let serializedAuthors = dict?["authors"] as? [JsonDictionary]
        authors = serializedAuthors?.map {
            Author(dictionary: $0, entity: self.entity)
        }
    }
    
    override public class func initialize()
    {
        guard self === AuthorObjectStore.self else { return }
        configureValueTransformers()
    }
    
    public func save()
    {
        guard let authors = self.authors else { return }
        
        let dict: NSDictionary = [
            "version": version,
            "authors": authors.dictionaryRepresentation]
        
        if let URL = NSURL.documentDirectoryURL(forFileName: FileName, type: "json"),
            data = try? dict.serializeAsJson() {
            do {
                try data.writeToURL(URL, options: NSDataWritingOptions(rawValue: 0))
            }
            catch {
                print("WARNING: Unable to save data as JSON")
            }
        }
    }
}

// MARK: - Configuring Value Transformers
extension AuthorObjectStore
{
    public class func configureValueTransformers()
    {
        NSValueTransformer.setValueTransformer(DateTransformer(), forName: String(DateTransformer.transformerName))
        NSValueTransformer.setValueTransformer(StringArrayTransformer(), forName: String(StringArrayTransformer.transformerName))
    }
}

// MARK: - DataSource Support

public extension AuthorObjectStore
{
    public func titleForSection(section: NSInteger) -> String {
        return authors?[section].fullName ?? ""
    }
    
    public func numberOfSections() -> NSInteger {
        return authors?.count ?? 0
    }
    
    public func numberOfRows(inSection section: NSInteger) -> NSInteger {
        return authors?[section].books?.count ?? 0
    }
    
    public func bookAtIndexPath(indexPath: NSIndexPath) -> Book? {
        return authors?[indexPath.section].books?[indexPath.row]
    }
}