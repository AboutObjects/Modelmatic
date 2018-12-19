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
    
    private var storageMode = StorageMode.file {
        willSet {
            segmentedControl.selectedSegmentIndex = newValue == .file ? 1 : 0
        }
    }
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    required override init()
    {
        let bundle = Bundle(for: AuthorObjectStore.self)
        guard let modelURL = bundle.url(forResource: authorsModelName, withExtension: "momd") else {
            fatalError("Unable to find model named \(authorsModelName).momd in bundle \(bundle)")
        }
        model = NSManagedObjectModel(contentsOf: modelURL)
        authorEntity = model.entitiesByName[Author.entityName]
        bookEntity = model.entitiesByName[Book.entityName]
        super.init()
        AuthorObjectStore.initialization
    }
    
    private static let initialization: Void = {
        configureValueTransformers()
        configureURLProtocols()
    }()
}

// MARK: - Persistence API
extension AuthorObjectStore
{
    func fetch(_ completion: @escaping () -> Void) {
        if case StorageMode.webService = storageMode {
            fetchObjects(fromWeb: restUrlString, mainQueueHandler: completion) } else {
            fetchObjects(fromFile: authorsFileName, completion: completion)
        }
    }

    func save() {
        if case StorageMode.webService = storageMode {
            save(toWeb: restUrlString) } else {
            save(toFile: authorsFileName) }
    }
    
    func toggleStorageMode() {
        storageMode = storageMode == .file ? .webService : .file
    }
}

// MARK: - Storing and retrieving data
extension AuthorObjectStore
{
    private func fetchObjects(fromFile fileName: String, completion: () -> Void)
    {
        guard let dict = NSDictionary.dictionary(contentsOfJSONFile: fileName), let authorDicts = dict["authors"] as? [JsonDictionary] else {
            return
        }
        version = dict["version"] as? NSNumber ?? NSNumber(value: 0)
        authors = authorDicts.map { Author(dictionary: $0, entity: self.authorEntity) }
        completion()
    }
    
    private func fetchObjects(fromWeb urlString: String, mainQueueHandler: @escaping () -> Void)
    {
        guard let url = URL(string: urlString) else { fatalError("Invalid url string: \(urlString)") }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            self?.handleFetch(data: data, response: response, error: error, mainQueueHandler: mainQueueHandler)
        }
        task.resume()
    }
    
    private func handleFetch(data: Data?, response: URLResponse?, error: Error?, mainQueueHandler: @escaping () -> Void) {
        guard error == nil else {
            print("WARNING: Save error: \(error!)")
            return
        }
        guard (response as? HTTPURLResponse)?.valid == true else {
            print("WARNING: Invalid response code \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            return
        }
        decodeAuthors(data)
        OperationQueue.main.addOperation { mainQueueHandler() }
    }
    
    private func save(toWeb urlString: String)
    {
        guard let url = URL(string: urlString) else { fatalError("Invalid url string: \(urlString)") }
        guard let data = encodeAuthors() else { print("WARNING: save failed with url: \(urlString)"); return }
        
        let request = URLRequest.putRequest(url: url, data: data)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.handleSave(data: data, response: response, error: error)
        }
        task.resume()
    }
    
    private func handleSave(data: Data?, response: URLResponse?, error: Error?) {
        guard error == nil else {
            print("WARNING: Save error: \(error!)")
            return
        }
        guard (response as? HTTPURLResponse)?.valid == true else {
            print("WARNING: Invalid response code \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            return
        }
    }
    
    private func save(toFile fileName: String)
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

// MARK: - Encoding/decoding
extension AuthorObjectStore
{
    private func encodeAuthors() -> Data?
    {
        guard let authors = self.authors else { return nil }
        let dict: NSDictionary = ["version": version, "authors": authors.dictionaryRepresentation]
        return try? dict.serializeAsJson(pretty: true)
    }
    
    private func decodeAuthors(_ data: Data?)
    {
        guard let data = data, let d = try? data.deserializeJson(), let dict = d as? JsonDictionary,
            let authorDicts = dict["authors"] as? [JsonDictionary] else { return }
        version = dict["version"] as? NSNumber ?? NSNumber(value: 0)
        authors = authorDicts.map { Author(dictionary: $0, entity: authorEntity) }
    }
}

// MARK: - DataSource support
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

// MARK: - URL protocols and value transformers
extension AuthorObjectStore
{
    private class func configureValueTransformers()
    {
        ValueTransformer.setValueTransformer(DateTransformer(), forName: DateTransformer.transformerName)
        ValueTransformer.setValueTransformer(StringArrayTransformer(), forName: StringArrayTransformer.transformerName)
    }
    
    private class func configureURLProtocols()
    {
        URLProtocol.registerClass(HttpSessionProtocol.self)
    }
}
