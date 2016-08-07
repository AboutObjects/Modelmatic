import UIKit
import XCTest
import CoreData
import Modelmatic

class ModelTests: XCTestCase
{
    var model: NSManagedObjectModel!
    var responseDict: [String: AnyObject]!
    var authorDicts: [[String: AnyObject]]!
    
    override func setUp() {
        super.setUp()
        
        let plistURL = NSBundle(forClass: self.dynamicType).URLForResource("Authors", withExtension: "plist")
        responseDict = NSDictionary(contentsOfURL: plistURL!) as! [String: AnyObject]
        authorDicts = responseDict["authors"] as! [[String: AnyObject]]
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
        let bookDict = authorDict["books"]![0] as! [String: AnyObject]
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
        let bookDict = authorDict["books"]![0] as! [String: AnyObject]
        let bookEntity = model.entitiesByName["Book"]!
        
        let book = BookClass.init(dictionary: bookDict, entity: bookEntity)
        
        print(book)
    }
}
