//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation
import CoreData
import Modelmatic

let authorsModelName = "Authors"
let authorsFileName = "Authors"

private let restUrlString = "http://www.aboutobjects.com/modelmatic?resource=Authors"

enum StorageMode {
    case webService
    case file
}

class AuthorObjectStore: NSObject
{
    let model: NSManagedObjectModel!
    let entity: NSEntityDescription!
    var version: NSNumber = 0
    var authors: [Author]?
    
    var storageMode = StorageMode.file {
        willSet {
            segmentedControl.selectedSegmentIndex = newValue == .file ? 1 : 0
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    required  override init()
    {
        let modelURL = NSBundle(forClass: AuthorObjectStore.self).URLForResource(authorsModelName, withExtension: "momd")
        model = NSManagedObjectModel(contentsOfURL: modelURL!) // Crash here if model URL is invalid.
        entity = model.entitiesByName[Author.entityName]
        super.init()
    }
    
    override  class func initialize() {
        guard self === AuthorObjectStore.self else { return }
        configureValueTransformers()
        configureURLProtocols()
    }
    
    func toggleStorageMode() {
        storageMode = storageMode == .file ? .webService : .file
    }
}

// MARK: - Encoding and Decoding Authors
extension AuthorObjectStore
{
    func encodeAuthors() -> NSData?
    {
        guard let authors = self.authors else { return nil }
        let dict: NSDictionary = ["version": version, "authors": authors.dictionaryRepresentation]
        return try? dict.serializeAsJson(pretty: true)
    }
    
    func decodeAuthors(data: NSData?)
    {
        guard let data = data, dict = try? data.deserializeJson(),
            authorDicts = dict["authors"] as? [JsonDictionary] else { return }
        version = dict["version"] as? NSNumber ?? NSNumber(int: 0)
        authors = authorDicts.map { Author(dictionary: $0, entity: entity) }
    }
}

// MARK: - Fetching and Saving Data
extension AuthorObjectStore
{
    func fetch(completion: () -> Void) {
        if case StorageMode.webService = storageMode {
            fetchObjects(fromWeb: restUrlString, completion: completion) } else {
            fetchObjects(fromFile: authorsFileName, completion: completion)
        }
    }
    
    func fetchObjects(fromFile fileName: String, completion: () -> Void)
    {
        guard let dict = NSDictionary.dictionary(contentsOfJSONFile: fileName), authorDicts = dict["authors"] as? [JsonDictionary] else {
            return
        }
        version = dict["version"] as? NSNumber ?? NSNumber(int: 0)
        authors = authorDicts.map { Author(dictionary: $0, entity: self.entity) }
        completion()
    }
    
    func fetchObjects(fromWeb urlString: String, completion: () -> Void)
    {
        guard let url = NSURL(string: urlString) else { fatalError("Invalid url string: \(urlString)") }
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { data, response, error in
            guard let response = response as? NSHTTPURLResponse where error == nil && response.valid else {
                print("WARNING: unable to fetch from web service with url \(urlString); error was \(error)")
                return
            }
            self.decodeAuthors(data)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                completion()
            }
        }
        task.resume()
    }
    
    func save()
    {
        if case StorageMode.webService = storageMode {
            save(toWeb: restUrlString) } else {
            save(toFile: authorsFileName) }
    }
    
    func save(toWeb urlString: String)
    {
        guard let url = NSURL(string: urlString) else { fatalError("Invalid url string: \(urlString)") }
        guard let data = encodeAuthors() else { print("WARNING: save failed with url: \(urlString)"); return }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.HTTPBody = data
        request.setValue(String(data.length), forHTTPHeaderField: "Content-Length")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard let response = response as? NSHTTPURLResponse where error == nil && response.valid else {
                print("WARNING: unable to save to web service with url \(urlString); error was \(error)")
                return
            }
        }
        task.resume()
    }
    
    func save(toFile fileName: String)
    {
        guard let
            data = encodeAuthors(),
            url = NSURL.documentDirectoryURL(forFileName: authorsFileName, type: "json") else { return }
        
        do {
            try data.writeToURL(url, options: NSDataWritingOptions(rawValue: 0))
        }
        catch {
            print("WARNING: Unable to save data as JSON")
        }
    }
}

// MARK: - Configuring Value Transformers
extension AuthorObjectStore
{
    class func configureValueTransformers()
    {
        NSValueTransformer.setValueTransformer(DateTransformer(), forName: String(DateTransformer.transformerName))
        NSValueTransformer.setValueTransformer(StringArrayTransformer(), forName: String(StringArrayTransformer.transformerName))
    }
    
    class func configureURLProtocols()
    {
        NSURLProtocol.registerClass(HttpSessionProtocol.self)
    }
}

// MARK: - DataSource Support

extension AuthorObjectStore
{
    func titleForSection(section: NSInteger) -> String {
        return authors?[section].fullName ?? ""
    }
    
    func numberOfSections() -> NSInteger {
        return authors?.count ?? 0
    }
    
    func numberOfRows(inSection section: NSInteger) -> NSInteger {
        return authors?[section].books?.count ?? 0
    }
    
    func bookAtIndexPath(indexPath: NSIndexPath) -> Book? {
        return authors?[indexPath.section].books?[indexPath.row]
    }
}