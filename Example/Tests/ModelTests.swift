import UIKit
import XCTest
import CoreData
import Modelmatic

// IMPORTANT: Make Example app API visible to XCTest
@testable import Modelmatic_Example


let authorIdKey = "author_id"
let firstNameKey = "firstName"
let lastNameKey = "lastName"
let booksKey = "books"

let bookIdKey = "book_id"
let titleKey = "title"
let yearKey = "year"
let ratingKey = "rating"
let favoriteKey = "favorite"

let bookId1 = "3401"
let title1 = "War of the Worlds"
let year1 = "2009"
let rating1 = 3
let favorite1 = true

let bookId2 = "3402"
let title2 = "The Time Machine"
let year2 = "2015"

let authorId1 = "105"
let firstName1 = "H. G."
let lastName1 = "Wells"

let bookDict1 = [
    bookIdKey: bookId1,
    titleKey: title1,
    yearKey: year1
    ] as JsonDictionary

let bookDict2 = [
    bookIdKey: bookId2,
    titleKey: title2,
    yearKey: year2
    ] as JsonDictionary

let bookDict3 = [
    bookIdKey: bookId1,
    titleKey: title1,
    yearKey: year1,
    ratingKey: rating1,
    favoriteKey: favorite1
    ] as JsonDictionary

let bookDicts = [ bookDict1, bookDict2 ]

let authorDict1 = [
    authorIdKey: authorId1,
    firstNameKey: firstName1,
    lastNameKey: lastName1,
    booksKey: bookDicts
    ] as JsonDictionary

let authorDict2 = [
    authorIdKey: authorId1,
    firstNameKey: firstName1,
    lastNameKey: lastName1,
    ] as JsonDictionary

class ModelTests: XCTestCase
{
    var model: NSManagedObjectModel!
    var responseDict: JsonDictionary!
    
    lazy var bookEntity: NSEntityDescription = self.model.entitiesByName["Book"]!
    lazy var authorEntity: NSEntityDescription = self.model.entitiesByName["Author"]!
    
    override func setUp() {
        super.setUp()
        let momdURL = NSBundle(forClass: self.dynamicType).URLForResource("Authors", withExtension: "momd")
        model = NSManagedObjectModel(contentsOfURL: momdURL!)
        XCTAssertNotNil(model)
        print("")
    }
    override func tearDown() {
        print("")
        super.tearDown()
    }
    
    func testPopulateBook()
    {
        let book = Book(dictionary: bookDict1, entity: bookEntity)
        XCTAssertEqual(book.externalID.integerValue, Int(bookId1))
        XCTAssertEqual(book.title, title1)
        XCTAssertEqual(book.year, year1)
    }
    
    func testPopulateBookWithIntegerAndBoolValues()
    {
        let book = Book(dictionary: bookDict3, entity: bookEntity)
        XCTAssertEqual(book.rating, rating1)
        XCTAssertEqual(book.favorite, favorite1)
    }
    
    func testPopulateAuthor()
    {
        let author = Author(dictionary: authorDict1, entity: authorEntity)

        guard let books = author.books else {
            XCTFail("books property should contain an array of Book objects after decoding Author")
            return // I know, I know...
        }
        
        XCTAssertEqual(author.externalID.integerValue, Int(authorId1))
        XCTAssertEqual(author.firstName, firstName1)
        XCTAssertEqual(author.lastName, lastName1)
        XCTAssertEqual(books.count, bookDicts.count)
        XCTAssertTrue(books[0].author == author)
    }
    
    func testRemoveBook()
    {
        let author = Author(dictionary: authorDict1, entity: authorEntity)
        let expectedCount = author.books!.count - 1
        author.books?.removeLast()
        XCTAssertEqual(author.books?.count, expectedCount)
    }
    
    func testAddBook()
    {
        let author = Author(dictionary: authorDict2, entity: authorEntity)
        print(author)
        let book = Book(dictionary: bookDict1, entity: bookEntity)
        if author.books == nil { author.books = [Book]() }
        author.books?.append(book)
        XCTAssertEqual(author.books?.count, 1)
        
        // TODO: Adding related objects doesn't automatically set back pointers (and vice versa).
        // Consider adding API for this.
        //
        //   XCTAssertEqual(book.author, author)
    }
    
    func testEncodeBook()
    {
        let book = Book(dictionary: JsonDictionary(), entity: bookEntity)
        book.externalID = NSNumber(integer: Int(bookId1)!)
        book.title = title1
        book.year = year1
        book.rating = rating1
        book.favorite = favorite1
        
        let dict = book.dictionaryRepresentation
        XCTAssertTrue(dict[bookIdKey] as! Int == book.externalID.integerValue &&
            dict[titleKey] as! String == title1 &&
            dict[yearKey] as! String == year1 &&
            dict[ratingKey] as! Int == rating1 &&
            dict[favoriteKey] as! Bool == favorite1)
    }
    
    func testEncodeAuthor()
    {
        let author = Author(dictionary: authorDict1, entity: authorEntity)
        let dict = author.dictionaryRepresentation
        XCTAssertTrue(dict[authorIdKey] as? String == authorId1 &&
            dict[firstNameKey] as? String == firstName1 &&
            dict[lastNameKey] as? String == lastName1 &&
            dict[booksKey]?.count == bookDicts.count &&
            dict[booksKey]! is [JsonDictionary]
        )
    }
}

//extension ModelTests
//{
//
//    func testEntityDescriptions()
//    {
//        for entity in model.entities {
//            print("Attributes: %@", entity.attributesByName)
//            print("Relationships: %@", entity.relationshipsByName)
//            print("Class: %@", entity.managedObjectClassName)
//        }
//    }
//
//    func testAttributes()
//    {
//        let authorEntity = self.model.entitiesByName["Author"];
//        let firstNameAttribute = authorEntity!.attributesByName["firstName"];
//        print(firstNameAttribute)
//        print(firstNameAttribute?.name)
//        print(firstNameAttribute?.attributeType)
//        print(firstNameAttribute?.valueTransformerName)
//        print(firstNameAttribute?.versionHash)
//    }
//
//        func testStuff()
//        {
//            let s = NSClassFromString("NSString") as! NSString.Type
//            print(s)
//    
//            guard let BookClass: ModelObject.Type = NSClassFromString("Book") as? ModelObject.Type else {
//                abort()
//            }
//            print(BookClass)
//    
//            let authorDict = authorDicts[0]
//            let bookDict = authorDict["books"]![0] as! JsonDictionary
//            let bookEntity = model.entitiesByName["Book"]!
//    
//            let book = BookClass.init(dictionary: bookDict, entity: bookEntity)
//            
//            print(book)
//        }
//
//        func testDecodeBookObjectAndSerializeData()
//        {
//            guard let fileUrl = NSBundle(forClass: self.dynamicType).URLForResource("Authors", withExtension: "json"),
//                data = NSData(contentsOfURL: fileUrl) else {
//                    return
//            }
//    
//            guard let dict = try? data.deserializeJson() else {
//                print("Unable to load JSON from Authors.json")
//                return
//            }
//    
//            guard let authors = dict["authors"] as AnyObject as? [AnyObject],
//                author = authors[0] as AnyObject as? JsonDictionary,
//                books = author["books"]! as AnyObject as? [JsonDictionary],
//                book = books[0] as AnyObject as? JsonDictionary else {
//                    return
//            }
//    
//            print(book)
//    
//            let modelName = "Authors"
//    
//            guard let modelURL = NSBundle(forClass: Book.self).URLForResource(modelName, withExtension: "momd"),
//                model = NSManagedObjectModel(contentsOfURL: modelURL) else {
//                    print("Unable to load model \(modelName)")
//                    return
//            }
//    
//            guard let entity = model.entitiesByName[Book.entityName] else {
//                return
//            }
//    
//            let bookObj = Book(dictionary: book, entity: entity)
//            print(bookObj)
//    
//            // Decode model object(s)
//            let bookDict = bookObj.dictionaryRepresentation
//    
//            // Serialize data
//            if let data = try? NSJSONSerialization.dataWithJSONObject(bookDict, options: NSJSONWritingOptions(rawValue: 0)) {
//                // Do something with the data...
//            }
//        }
//}
