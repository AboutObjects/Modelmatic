import UIKit
import XCTest
import CoreData
import Modelmatic


class ModelTests: XCTestCase
{
    var model: NSManagedObjectModel!
    var responseDict: JsonDictionary!
    var authorDicts: [JsonDictionary]!
    
    override func setUp() {
        super.setUp()
        
        let plistURL = NSBundle(forClass: self.dynamicType).URLForResource("Authors", withExtension: "plist")
        responseDict = NSDictionary(contentsOfURL: plistURL!) as! JsonDictionary
        authorDicts = responseDict["authors"] as! [JsonDictionary]
        XCTAssertNotNil(authorDicts)
        
        let momdURL = NSBundle(forClass: self.dynamicType).URLForResource("Authors", withExtension: "momd")
        model = NSManagedObjectModel(contentsOfURL: momdURL!)
        XCTAssertNotNil(model)
        print("")
    }
    override func tearDown() {
        print("")
        super.tearDown()
    }
    
    
    func testDeserializeBookDataAndEncode()
    {
        guard let fileUrl = NSBundle(forClass: self.dynamicType).URLForResource("Authors", withExtension: "json"),
            data = NSData(contentsOfURL: fileUrl) else {
                return
        }
        
        guard let dict = try? data.deserializeJson() else {
            print("Unable to load JSON from Authors.json")
            return
        }
        
        guard let authors = dict["authors"] as AnyObject as? [AnyObject],
            author = authors[0] as AnyObject as? JsonDictionary,
            books = author["books"]! as AnyObject as? [JsonDictionary],
            book = books[0] as AnyObject as? JsonDictionary else {
                return
        }
        
        print(book)
        
        let modelName = "Authors"
        
        guard let modelURL = NSBundle(forClass: Book.self).URLForResource(modelName, withExtension: "momd"),
            model = NSManagedObjectModel(contentsOfURL: modelURL) else {
                print("Unable to load model \(modelName)")
                return
        }
        
        guard let entity = model.entitiesByName[Book.entityName] else {
                return
        }

        let bookObj = Book(dictionary: book, entity: entity)
        print(bookObj)
    }
    
    func testDecodeBookObjectAndSerializeData()
    {
        guard let fileUrl = NSBundle(forClass: self.dynamicType).URLForResource("Authors", withExtension: "json"),
            data = NSData(contentsOfURL: fileUrl) else {
                return
        }
        
        guard let dict = try? data.deserializeJson() else {
            print("Unable to load JSON from Authors.json")
            return
        }
        
        guard let authors = dict["authors"] as AnyObject as? [AnyObject],
            author = authors[0] as AnyObject as? JsonDictionary,
            books = author["books"]! as AnyObject as? [JsonDictionary],
            book = books[0] as AnyObject as? JsonDictionary else {
                return
        }
        
        print(book)
        
        let modelName = "Authors"
        
        guard let modelURL = NSBundle(forClass: Book.self).URLForResource(modelName, withExtension: "momd"),
            model = NSManagedObjectModel(contentsOfURL: modelURL) else {
                print("Unable to load model \(modelName)")
                return
        }
        
        guard let entity = model.entitiesByName[Book.entityName] else {
            return
        }
        
        let bookObj = Book(dictionary: book, entity: entity)
        print(bookObj)
        
        // Decode model object(s)
        let bookDict = bookObj.dictionaryRepresentation
        
        // Serialize data
        if let data = try? NSJSONSerialization.dataWithJSONObject(bookDict, options: NSJSONWritingOptions(rawValue: 0)) {
            // Do something with the data...
        }
    }
    
    func testEntityDescriptions()
    {
        for entity in model.entities {
            print("Attributes: %@", entity.attributesByName)
            print("Relationships: %@", entity.relationshipsByName)
            print("Class: %@", entity.managedObjectClassName)
        }
    }
    
    func testAttributes()
    {
        let authorEntity = self.model.entitiesByName["Author"];
        let firstNameAttribute = authorEntity!.attributesByName["firstName"];
        print(firstNameAttribute)
        print(firstNameAttribute?.name)
        print(firstNameAttribute?.attributeType)
        print(firstNameAttribute?.valueTransformerName)
        print(firstNameAttribute?.versionHash)
    }
    
    func testPopulateBook()
    {
        let authorDict = authorDicts[0]
        let bookDict = authorDict["books"]![0] as! JsonDictionary
        let bookEntity = model.entitiesByName["Book"]!
        let book = Book(dictionary: bookDict, entity: bookEntity)
        print(book)
        
        XCTAssertEqual(book.title, bookDict["title"] as? String)
    }
    
    func testPopulateAuthor()
    {
        let authorDict = authorDicts[0]
        let authorEntity = model.entitiesByName["Author"]!
        let author = Author(dictionary: authorDict, entity: authorEntity)
        print(author)
        
        XCTAssertEqual(author.lastName, authorDict["lastName"] as? String)
    }
    
    func testStuff()
    {
        let s = NSClassFromString("NSString") as! NSString.Type
        print(s)
        
        guard let BookClass: ModelObject.Type = NSClassFromString("Book") as? ModelObject.Type else {
            abort()
        }
        print(BookClass)
        
        let authorDict = authorDicts[0]
        let bookDict = authorDict["books"]![0] as! JsonDictionary
        let bookEntity = model.entitiesByName["Book"]!
        
        let book = BookClass.init(dictionary: bookDict, entity: bookEntity)
        
        print(book)
    }
    
    
}
