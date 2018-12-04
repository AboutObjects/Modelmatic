import UIKit
import XCTest
import CoreData
import Modelmatic

// Makes Example app API visible to XCTest
@testable import Modelmatic_Example

let authorIdKey = "author_id"
let firstNameKey = "firstName"
let lastNameKey = "lastName"
let booksKey = "books"
let pricingKey = "pricing"

let bookIdKey = "book_id"
let titleKey = "title"
let yearKey = "year"
let ratingKey = "rating"
let favoriteKey = "favorite"
let retailPriceJsonKey = "retail_price"

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

let retailPrice1 = 14.99
let retailPrice2 = 12.99

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

let bookDictWithPricingDict = [
    bookIdKey: bookId1,
    titleKey: title1,
    yearKey: year1,
    pricingKey: [
        "pricing_id": 101,
        retailPriceJsonKey: retailPrice1
    ]
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
    
    lazy var bookEntity: NSEntityDescription = model.entitiesByName["Book"]!
    lazy var authorEntity: NSEntityDescription = model.entitiesByName["Author"]!
    lazy var pricingEntity: NSEntityDescription = model.entitiesByName["Pricing"]!
    
    override func setUp() {
        super.setUp()
        let momdURL = Bundle(for: type(of: self)).url(forResource: "Authors", withExtension: "momd")
        model = NSManagedObjectModel(contentsOf: momdURL!)
        XCTAssertNotNil(model)
        print("")
    }
    override func tearDown() {
        print("")
        super.tearDown()
    }
    
    func testPopulateObjectAttributes()
    {
        let book = Book(dictionary: bookDict1, entity: bookEntity)
        XCTAssertEqual(book.bookId!.intValue, Int(bookId1))
        XCTAssertEqual(book.title, title1)
        XCTAssertEqual(book.year, year1)
    }
    
    func testPopulateObjectAttributesWithIntegerAndBoolValues()
    {
        let book = Book(dictionary: bookDict3, entity: bookEntity)
        XCTAssertEqual(book.rating.rawValue, rating1)
        XCTAssertEqual(book.favorite.boolValue, favorite1)
    }
    
    func testPopulateObjectAndToManyRelationshipWithDictionary()
    {
        let author = Author(dictionary: authorDict1, entity: authorEntity)

        guard let books = author.books else {
            XCTFail("books property expected to contain an array of Book objects after decoding Author")
            return
        }
        
        XCTAssertEqual(author.authorId!.intValue, Int(authorId1))
        XCTAssertEqual(author.firstName, firstName1)
        XCTAssertEqual(author.lastName, lastName1)
        XCTAssertEqual(books.count, bookDicts.count)
        XCTAssertTrue(books[0].author == author)
    }
    
    func testRemoveObjectFromRelationship()
    {
        let author = Author(dictionary: authorDict1, entity: authorEntity)
        let expectedCount = author.books!.count - 1
        author.books?.removeLast()
        XCTAssertEqual(author.books?.count, expectedCount)
    }
    
    func testAddObjectToRelationshipWithDictionary()
    {
        let author = Author(dictionary: authorDict2, entity: authorEntity)
        guard let relationship = author.entity.relationshipsByName[booksKey] else {
            XCTFail("Author entity expected to have a relationship named 'books'")
            return
        }
        author.addObjects(toRelationship: relationship, withValuesFromDictionaries: [bookDict1])
        XCTAssertEqual(author.books?.count, 1)
    }
    
    func testAddObjectsToRelationshipWithDictionary()
    {
        let author = Author(dictionary: authorDict2, entity: authorEntity)
        guard let relationship = author.entity.relationshipsByName[booksKey] else {
            XCTFail("Author entity expected to have a relationship named 'books'")
            return
        }
        author.addObjects(toRelationship: relationship, withValuesFromDictionaries: bookDicts)
        XCTAssertEqual(author.books?.count, 2)
    }
    
    func testSetObjectForToOneRelationshipWithDictionary()
    {
        let book = Book(dictionary: bookDict1, entity: bookEntity)
        guard let relationship = book.entity.relationshipsByName["pricing"] else {
            XCTFail("Book entity expected to have a relationship named 'pricing'")
            return
        }
        book.setObject(forRelationship: relationship, withValuesFromDictionary: ["pricing": [retailPriceJsonKey: retailPrice1]])
        XCTAssertEqual(book.pricing!.retailPrice!, retailPrice1, accuracy: 0.1)
    }
    
    func testFlattenedAttribute()
    {
        let book = Book(dictionary: bookDictWithPricingDict, entity: bookEntity)
        XCTAssertNotNil(book.retailPrice)
        XCTAssertEqual(book.pricing!.retailPrice!, retailPrice1, accuracy: 0.1)
    }
    
    func testAddObjectToExistingRelationship()
    {
        let author = Author(dictionary: authorDict1, entity: authorEntity)
        let book = Book(dictionary: bookDict3, entity: bookEntity)
        try! author.add(modelObject: book, forKey: booksKey)
        XCTAssertEqual(author.books?.count, 3)
        XCTAssertEqual(book.author, author)
    }
    
    func testAddObjectToEmptyRelationship()
    {
        let author = Author(dictionary: authorDict2, entity: authorEntity)
        let book = Book(dictionary: bookDict1, entity: bookEntity)
        try! author.add(modelObject: book, forKey: booksKey)
        XCTAssertEqual(author.books?.count, 1)
        XCTAssertEqual(book.author, author)
    }
    
    func testAddObjectToNonExistentRelationship()
    {
        let author = Author(dictionary: authorDict2, entity: authorEntity)
        let book = Book(dictionary: bookDict1, entity: bookEntity)
        XCTAssertThrowsError(try author.add(modelObject: book, forKey: "nonexistent_key"))
    }
    
    func testSetObjectForToOneRelationship()
    {
        let expectedPrice = 19.99
        let book = Book(dictionary: bookDict1, entity: bookEntity)
        let pricing = Pricing(dictionary: [retailPriceJsonKey: expectedPrice], entity: pricingEntity)
        try! book.set(modelObject: pricing, forKey: "pricing")
        XCTAssertEqual(book.pricing!.retailPrice!, expectedPrice, accuracy: 0.1)
        XCTAssertEqual(pricing.book, book)
    }
    
    func testSetObjectForNonexistentToOneRelationship()
    {
        let expectedPrice = 19.99
        let book = Book(dictionary: bookDict1, entity: bookEntity)
        let pricing = Pricing(dictionary: [retailPriceJsonKey: expectedPrice], entity: pricingEntity)
        XCTAssertThrowsError(try book.set(modelObject: pricing, forKey: "nonexistent_key"))
    }
    
    func testEncodeObjectAttributes()
    {
        let book = Book(dictionary: JsonDictionary(), entity: bookEntity)
        book.bookId = NSNumber(value: Int(bookId1)! as Int)
        book.title = title1
        book.year = year1
        book.rating = Stars(rawValue: rating1) ?? .zero
        book.favorite = Heart(isFavorite: Optional(favorite1))
        
        let dict = book.dictionaryRepresentation
        XCTAssertTrue(dict[bookIdKey] as! Int == book.bookId!.intValue &&
            dict[titleKey] as! String == title1 &&
            dict[yearKey] as! String == year1 &&
            dict[ratingKey] as! Int == rating1 &&
            dict[favoriteKey] as! Bool == favorite1)
    }
    
    func testEncodeFlattenedAttributeValue()
    {
        let book = Book(dictionary: JsonDictionary(), entity: bookEntity)
        let pricing = Pricing(dictionary: [retailPriceJsonKey: retailPrice1], entity: pricingEntity)
        book.pricing = pricing
        pricing.book = book
        
        book.retailPrice = retailPrice2
        let pricingDict = book.dictionaryRepresentation["pricing"] as? JsonDictionary
        XCTAssertEqual(pricingDict![retailPriceJsonKey] as? Double, retailPrice2)
    }

    func testEncodeFlattenedAttributeValueWithoutNestedObject()
    {
        let book = Book(dictionary: JsonDictionary(), entity: bookEntity)
        book.retailPrice = retailPrice2
        let pricingDict = book.dictionaryRepresentation["pricing"] as? JsonDictionary
        print(book.dictionaryRepresentation)
        XCTAssertEqual(pricingDict![retailPriceJsonKey] as? Double, retailPrice2)
    }

    func testEncodeParentObjectAndChildrenWithToManyRelationship()
    {
        let author = Author(dictionary: authorDict1, entity: authorEntity)
        let dict = author.dictionaryRepresentation
        XCTAssertTrue(dict[authorIdKey] as? String == authorId1 &&
            dict[firstNameKey] as? String == firstName1 &&
            dict[lastNameKey] as? String == lastName1 &&
            (dict[booksKey] as! [JsonDictionary]).count == bookDicts.count &&
            dict[booksKey]! is [JsonDictionary]
        )
    }
    
    func testEncodeParentObjectWithEmptyToManyRelationship()
    {
        let author = Author(dictionary: authorDict2, entity: authorEntity)
        let dict = author.dictionaryRepresentation
        XCTAssertTrue(dict[authorIdKey] as? String == authorId1 &&
            dict[firstNameKey] as? String == firstName1 &&
            dict[lastNameKey] as? String == lastName1 &&
            dict[booksKey] is Optional<NSNull>
        )
    }
}
