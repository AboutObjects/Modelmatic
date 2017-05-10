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
    let authorEntity: NSEntityDescription!
    let bookEntity: NSEntityDescription!
    var version: NSNumber = 0
    var authors: [Author]?
    
    var storageMode = StorageMode.file {
        willSet {
            segmentedControl.selectedSegmentIndex = newValue == .file ? 1 : 0
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    required override init()
    {
        let modelURL = Bundle(for: AuthorObjectStore.self).url(forResource: authorsModelName, withExtension: "momd")
        model = NSManagedObjectModel(contentsOf: modelURL!) // Crash here if model URL is invalid.
        authorEntity = model.entitiesByName[Author.entityName]
        bookEntity = model.entitiesByName[Book.entityName]
        super.init()
        AuthorObjectStore.initialization
    }
    
    static let initialization: Void = {
        configureValueTransformers()
        configureURLProtocols()
    }()
    
    func toggleStorageMode() {
        storageMode = storageMode == .file ? .webService : .file
    }
}

// MARK: - Encoding and Decoding Authors
extension AuthorObjectStore
{
    func encodeAuthors() -> Data?
    {
        guard let authors = self.authors else { return nil }
        let dict: NSDictionary = ["version": version, "authors": authors.dictionaryRepresentation]
        return try? dict.serializeAsJson(pretty: true)
    }
    
    func decodeAuthors(_ data: Data?)
    {
        guard let data = data, let d = try? data.deserializeJson(), let dict = d as? JsonDictionary,
            let authorDicts = dict["authors"] as? [JsonDictionary] else { return }
        version = dict["version"] as? NSNumber ?? NSNumber(value: 0)
        authors = authorDicts.map { Author(dictionary: $0, entity: authorEntity) }
    }
}

// MARK: - Fetching and Saving Data
extension AuthorObjectStore
{
    func fetch(_ completion: @escaping () -> Void) {
        if case StorageMode.webService = storageMode {
            fetchObjects(fromWeb: restUrlString, completion: completion) } else {
            fetchObjects(fromFile: authorsFileName, completion: completion)
        }
    }
    
    func fetchObjects(fromFile fileName: String, completion: () -> Void)
    {
        guard let dict = NSDictionary.dictionary(contentsOfJSONFile: fileName), let authorDicts = dict["authors"] as? [JsonDictionary] else {
            return
        }
        version = dict["version"] as? NSNumber ?? NSNumber(value: 0)
        authors = authorDicts.map { Author(dictionary: $0, entity: self.authorEntity) }
        completion()
    }
    
    func fetchObjects(fromWeb urlString: String, completion: @escaping () -> Void)
    {
        guard let url = URL(string: urlString) else { fatalError("Invalid url string: \(urlString)") }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse , error == nil && response.valid else {
                print("WARNING: unable to fetch from web service with url \(urlString); error was \(String(describing: error))")
                return
            }
            self.decodeAuthors(data)
            OperationQueue.main.addOperation {
                completion()
            }
        }) 
        task.resume()
    }
    
    func save() {
        if case StorageMode.webService = storageMode {
            save(toWeb: restUrlString) } else {
            save(toFile: authorsFileName) }
    }
    
    func save(toWeb urlString: String)
    {
        guard let url = URL(string: urlString) else { fatalError("Invalid url string: \(urlString)") }
        guard let data = encodeAuthors() else { print("WARNING: save failed with url: \(urlString)"); return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = data
        request.setValue(String(data.count), forHTTPHeaderField: "Content-Length")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse , error == nil && response.valid else {
                print("WARNING: unable to save to web service with url \(urlString); error was \(String(describing: error))")
                return
            }
        }
        task.resume()
    }
    
    func save(toFile fileName: String)
    {
        guard let
            data = encodeAuthors(),
            let url = URL.documentDirectoryURL(forFileName: authorsFileName, type: "json") else { return }
        
        do {
            try data.write(to: url, options: NSData.WritingOptions(rawValue: 0))
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
        ValueTransformer.setValueTransformer(DateTransformer(), forName: DateTransformer.transformerName)
        ValueTransformer.setValueTransformer(StringArrayTransformer(), forName: StringArrayTransformer.transformerName)
    }
    
    class func configureURLProtocols()
    {
        URLProtocol.registerClass(HttpSessionProtocol.self)
    }
}

// MARK: - DataSource Support

extension AuthorObjectStore
{
    func titleForSection(_ section: NSInteger) -> String {
        return authors?[section].fullName ?? ""
    }
    
    func numberOfSections() -> NSInteger {
        return authors?.count ?? 0
    }
    func numberOfRows(inSection section: NSInteger) -> NSInteger {
        return authors?[section].books?.count ?? 0
    }
    
    func bookAtIndexPath(_ indexPath: IndexPath) -> Book? {
        return authors?[(indexPath as NSIndexPath).section].books?[(indexPath as NSIndexPath).row]
    }
    func removeBookAtIndexPath(_ indexPath: IndexPath) {
        authors?[(indexPath as NSIndexPath).section].books?.remove(at: (indexPath as NSIndexPath).row)
    }
}
