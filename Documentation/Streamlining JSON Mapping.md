footer: Copyright © 2016, [About Objects, Inc.](http://www.aboutobjects.com)
slidenumbers: true

![inline 300%](images/Logo-White.eps)
# [fit]_Streamlining_
# [fit]JSON Mapping
<br/>
#### Jonathan Lehr, Founder and VP, Training

---

## About Objects

* Reston, VA
* Full-stack consulting and training
* Roots: NeXT, OpenStep, WebObjects
* iOS from day one

---

## Why So Many Frameworks?

Number of hits yielded by a recent Github search for _swift json_:

### [fit] 574

Seems it's on a lot of peoples' radar.

---

## Goal: Automatic Encode/Decode

```json
{ "book_id": 42,
  "title": "The Time Machine",
  "rating": 3 }
```
```swift
public class Book: NSObject {
    public var bookId: Int
    public var title: String?    
    public var rating: Rating?
}
```

1. Mapping between keys and property names
2. Performing value transformations
3. Encoding and decoding model objects

---

## Stretch Goal: Object Graphs

```json
{ "author_id": 98,
  "first_name": "H. G.",
  "last_name": "Wells",
  "books": [
    { "book_id": 42,
      "title": "The Time Machine",
      "rating": 3 },
  ...    
```

Automatic encoding and decoding of:

1. Model objects nested to any depth
1. Nested arrays of model objects 

---

##  Object Graph in Memory

![inline 125%](images/ObjectGraph.eps)

---

## Popular Mapping Frameworks

You define mappings programmatically by:

* Providing a dictionary describing the mappings for a given class (e.g., RestKit)
* Defining mappings for each property in code (e.g., ObjectMapper, SwiftJSON)

---

## RestKit Example

```objectivec
    RKObjectMapping *bookMapping = [RKObjectMapping mappingForClass:Book.class];
    [bookMapping addAttributeMappingsFromDictionary:@{ 
        @"book_id": @"bookId",
        @"title": @"title",
        @"rating": @"rating",
    }];
    
    RKResponseDescriptor *descriptor = [RKResponseDescriptor 
        responseDescriptorWithMapping:bookMapping
        method:RKRequestMethodAny 
        pathPattern:nil
        keyPath:@"books"
        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

```

---

## ObjectMapper Example

```swift
class Book: Mappable {
    public var bookId: Int
    public var title: String?    
    public var rating: Rating?

    required init?(_ map: Map) {

    }

    // Mappable
    func mapping(map: Map) {
        bookId <- map["book_id"]
        title <- map["title"]
        rating <- map["rating"]
    }
}
```

---

## Issues

* Model is hard to visualize
* Maintenance can be awkward
* Strings in code reduce safety

---

# A Thought Experiment

---

Assumptions:

* Many popular frameworks require mappings to be defined programmatically
* A few allow mappings to be externalized as plist metadata
* This may seem unrelated, but **most iOS teams don't seem to be using Core Data**

---
## Core Data Model Editor

* Awesome tool for data modeling
* Defines mappings in a visual format
* Framework-level programmatic access

### But wait, it's only for Core Data, right?

Heh, heh

---

## [fit] Thought Experiment, Step 1

* Verify that the Model Editor and associated framework classes can be used independently
* The rest is a slam dunk
* We'll just need one other thing...

---

## Key-Value Coding (KVC)

* Introspection mechanism built into `NSObject`
* Allows properties to be accessed by name (key)
* Is the straw that stirs the drink

---

## Managed Object Model (MOM)

* Defines mappings between model objects and their external data representation
* Designed to support relational databases (object-relational mapping)
* **Can be loaded as `NSManagedObjectModel` instance at runtime**

---

## Entities

* Metadata description of domain object
* Lists two kinds of properties: attributes and relationships
* Defines mapping between JSON dictionary and Swift class
* **Instances of `NSEntityDescription` in `NSManagedObjectModel`**

---

## Attributes

* Metadata descriptions of individual values
* Define mappings between data elements and Swift properties
* **Instances of `NSAttributeDescription` in `NSEntityDescription`**

---

## Relationships

* Describe properties that refer to model objects
* Specify destination entity name, and optional inverse relationship
* Can be *to-one* or *to-many*
* **Instances of `NSRelationshipDescripton` in `NSEntityDescription`**

---

# [fit] Demo: Xcode Model Editor

---

## Add a Dash of KVC, Then Stir

Back to the thought experiment, we wondered:

* Could a managed object model (MOM) fully describe JSON mappings? (Hint: duh!)
* Could we use Key-Value Coding (KVC) to automate encode/decode? (Hint: duh!)
* Could JSON + MOM + KVC = +1?

---

## So, What's KVC?

**Quick definition:**

> KVC is built-in `NSObject` behavior that allows you to treat an object like a dictionary.

**Quick example:**

```swift
// Set author's 'firstName' property to "Fred"
author.setValue("Fred", forKey: "firstName")

// Initialize 'name' with the value of the author's 'firstName' property
let name = author.value(forKey: "firstName")
```

---

#  The Modelmatic Framework

---

## Modelmatic Cocoapod

* ModelObject base class that uses MOM + KVC to encode/decode automatically
* Example app + unit tests illustrate usage

---

## Modelmatic Example

```swift
// Assume we fetched JSON and deserialized it:
let json = ["author_id": 123, "first_name": "Fred", "last_name": "Smith", "books": [
        ["book_id": 234, "title": "Yadda, Yadda", "rating": 3],
        ["book_id": 456, "title": "Whee!", "rating": 5]
    ]
]

// Encode
let author = Author(dictionary: json, entity: entity)

// Work with the objects
author.firstName = "Frederick"
author.books[0]?.title = "War and Peace"

// Decode
let newJson = author.dictionaryRepresentation

// Contents of newJson:
```
```json
{ "author_id": 123, "first_name": "Frederick", "last_name": "Smith", "books": [
        { "book_id": 234, "title": "War and Peace", "rating": 3 },
        { "book_id": 456, "title": "Whee!", "rating": 5 }
    ]
}
```
---

## KVC and Swift Types


**KVC handles automatically:**

* ObjC types, even if wrapped in Optionals 👍🏻
* Bridged Swift types (`String`, `Int`, etc.) 👍🏻

**KVC needs a little help with:**

* Bridged Swift types wrapped in Optionals 👎🏻
* Non-bridged Swift types 👎🏻

---

## Working with Swift Types

For non-Objc properties, add a computed property prefixed with **_kvc**, as shown below:

```swift
    var retailPrice: Double?

    var kvc_retailPrice: Double {
        get { return retailPrice ?? 0.0 }
        set { retailPrice = Optional(newValue) }
    }
```

---

## Customizing Key Paths

---

## Value Transformations

---

## Flattened Attributes

---

## Managing Relationships

* Setting to-one relationship values
* Adding values to to-many relationships

---

# Example App

---

## Object Store

* Accesses JSON via `NSURLSessionDataTask`
* Uses `NSURLProtocol` to intercept and access locally stored JSON
* Can switch modes to directly access local storage

---

## Example App Data Model

![inline 120%](images/DataModel.png)

---

# [fit] Demo: Example App

---

# Benefits

* Comprehensive visual model
* Automates:
    * Object graph construction
    * Value transformation
    * Key path mappings
    * Flattening attributes
* Built-in model versioning

---

# Modelmatic + mogenerator

* **mogenerator** — command-line tool that generates base classes for Core Data entities
* Base classes can be regenerated whenever model changes
* Allows templates used for generating classes to be customized

---

## To Do:

* Lights-out property access for non-bridged types (dependent on Swift introspection)
* Add support for `NSManagedObject` subclasses
* Do clever things with model versions (TBD)
* Proposed: auto generate model from JSON

---

## Modelmatic Status

* Needs more unit tests
* Contributors welcome

---

# Q & A

---

# We're Hiring

### consultants with backgrounds in:
* iOS
* Android
* Middleware – Ruby and Java
* Backend – Java

---

#  Upcoming Classes
### Reston

#### 10/1 – 10/10  • iOS Development in Swift: Comprehensive
#### 10/1 – 10/10 • iOS Development in Objective-C: Comprehensive

### Cupertino

#### `10/1 – 10/10 ` • iOS Development in Swift: Comprehensive
#### `10/1 – 10/10 ` • iOS Development in Objective-C: Comprehensive

* View online: [Public schedule](www.aboutobjects.com/training/schedule.html)

