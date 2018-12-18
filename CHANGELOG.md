Changelog
=========


(unreleased)
------------
- Swift 4.2+readme (#30) [Jonathan Lehr]

  * Updated README
- Swift 4.2 (#29) [Jonathan Lehr]

  Swift 4.2 support --  no longer relies on Swift 3 ObjC inference.

  * Added missing `@objc` annotations
  * Fixed a crasher where `setValue(forKey:)` was being called with a nil transformed value.
  * Disabled Swift 3 ObjC inference
  * Version 0.6.4


0.6.4 (2018-12-18)
------------------
- Updated README. [Jonathan Lehr]
- Version 0.6.4. [Jonathan Lehr]
- Disabled Swift 3 ObjC inference. [Jonathan Lehr]
- Fixed a crasher where `setValue(forKey:)` was being called with a nil
  transformed value. [Jonathan Lehr]
- Added missing `@objc` annotations. [Jonathan Lehr]


0.6.3 (2018-12-04)
------------------
- Swift 4.2. [Jonathan Lehr]


0.6.2 (2017-05-10)
------------------
- Swift 3.1 (#28) [Jonathan Lehr]
- Update changelog for 0.6.1. [Jonathan Lehr]


0.6.1 (2016-11-03)
------------------
- Fix/Encode nil values (#27) [Jonathan Lehr]

  * We now explicitly encode nil values as `NSNull`
  * Configurable KVC prefix
  * Update Xcode build


0.6.0 (2016-10-20)
------------------
- Swift3 migration (#26) [Jonathan Lehr]

  ## Swift 3 Migration
  * Changed `JsonDictionary` type from `[String: AnyObject]` to `[String: Any]`
  * Changed framework method visibility from `public` to `open`

  ## Cocoapods/Travis Swift 3 updates/configuration
  * Updated podspec for 0.6.0
  * Updated xcode project version number
  * Updated Travis config for Xcode 8 and iOS 10.0
  * Modified Travis xcodebuild command to use `-destination` flag instead of `-sdk`


0.5.3 (2016-09-11)
------------------
- Version 0.5.3. [Jonathan Lehr]
- CocoaConf final slides. [Jonathan Lehr]
- Feature/add book scene (#23) [Jonathan Lehr]

  * Update podspec to Version 0.5.2
  * Make ModelObject visibility public universally so subclasses can customize behavior.
  * New AddBook scene - adding and deleting books
  * Cruft removal


0.5.2 (2016-09-08)
------------------
- Update podspec to Version 0.5.2. [Jonathan Lehr]
- Cruft removal. [Jonathan Lehr]
- Removed cover images. [Jonathan Lehr]
- Adding and deleting books. [Jonathan Lehr]

  * New AddBook scene
  * Deletion support in AuthorDataSource, plus cleanups
  * BooksController segues for AddBook scene, plus cleanups
- CocoaConf WIP. [Jonathan Lehr]
- ModelObject cleanup. [Jonathan Lehr]

  Make visibility public universally so subclasses can customize behavior.


0.5.1 (2016-09-06)
------------------
- Version 0.5.1. [Jonathan Lehr]
- Merge branch 'master' of https://github.com/AboutObjects/Modelmatic.
  [Jonathan Lehr]
- Fix/flattened attributes (#22) [Jonathan Lehr]

  * Moved unwind segue

  * Cleanups

  * Tags UI + enum properties

  * externalID and externalKeyPath renaming

  * Coalesce BookDetail and EditBook scenes #20

  * Eliminated BookDetailController to streamline code and user interaction
  * General UI cleanups

  * Demo flattened attributes in example app #21

  Encoding fixes for to-one related objects, including:
  * Auto-creation of nested dictionaries based on key paths specified in model
  * Setting flattened attribute values during encoding

  * Fix travis build warning
- Fix warning. [Jonathan Lehr]
- Change log updates. [Jonathan Lehr]


0.5.0 (2016-09-05)
------------------
- Demo flattened attributes in example app #21. [Jonathan Lehr]

  Encoding fixes for to-one related objects, including:
  * Auto-creation of nested dictionaries based on key paths specified in model
  * Setting flattened attribute values during encoding
- Coalesce BookDetail and EditBook scenes #20. [Jonathan Lehr]

  * Eliminated BookDetailController to streamline code and user interaction
  * General UI cleanups
- ExternalID and externalKeyPath renaming. [Jonathan Lehr]
- Tags UI + enum properties. [Jonathan Lehr]
- Cleanups. [Jonathan Lehr]
- Moved unwind segue. [Jonathan Lehr]
- Codefencing fix. [Jonathan Lehr]
- Version 0.4.3. [Jonathan Lehr]


0.4.3 (2016-08-27)
------------------
- Dynamically setting/adding child objects (#19) [Jonathan Lehr]

  Added methods to ModelObject for dynamically setting/adding children that also set parent references for any inverse relationships defined in the model.


0.4.2 (2016-08-25)
------------------
- Rename ModelObject methods containing the words 'serialize' and
  'deserialize' #5 (#16) [Jonathan Lehr]

  Also:
  * Cleaned up unit tests and added several new ones
  * Removed `public` modifier throughout example app codebase.
  * Plus other minor cleanups
- Replace 'encoding' with 'serialization'. [Jonathan Lehr]
- Update version to 0.4.1. [Jonathan Lehr]
- Update changelog. [Jonathan Lehr]


0.4.1 (2016-08-10)
------------------
- Small README fix. [Jonathan Lehr]
- #13 Mock web services with NSURLProtocol instead of Mocky.io (#15)
  [Jonathan Lehr]

  #14 Add UI to allow users to toggle between web and file system storage
  * Also, significant additions to the README documentation


0.4.0 (2016-08-09)
------------------
- Update for 0.3.3. [Jonathan Lehr]


0.3.3 (2016-08-09)
------------------
- Feature/json storage (#10) [Jonathan Lehr]

  * Fix changelog merge conflict

  * Remove merge artifact


0.3.2 (2016-08-09)
------------------
- Remove merge artifact. [Jonathan Lehr]
- Fix changelog merge conflict. [Jonathan Lehr]
- Switched storage type from plist to json. [Jonathan Lehr]
- Update CHANGELOG.md. [Jonathan Lehr]
- Add enhancements to example app from Codex HEAD (#8) [Jonathan Lehr]

  * Add enhancements to example app from Codex HEAD

  * Removed bogus tests.


0.3.1 (2016-08-08)
------------------
- Removed bogus tests. [Jonathan Lehr]


0.3.0 (2016-08-08)
------------------
- Add enhancements to example app from Codex HEAD. [Jonathan Lehr]
- Update README.md. [Jonathan Lehr]
- Update README.md. [Jonathan Lehr]
- Update travis-cocoapods link. [Jonathan Lehr]
- Update travis link. [Jonathan Lehr]
- Update travis and cocoapod links. [Jonathan Lehr]
- Version 0.2.0 (#3) [Jonathan Lehr]


0.2.0 (2016-08-07)
------------------
- Feature/add example (#1) [Jonathan Lehr]

  * Document technical requirements

  * Add example and tests
- Add ModelObject. [Jonathan Lehr]
- Revert image fix. [Jonathan Lehr]
- Image fix. [Jonathan Lehr]
- Podspec cleanup. [Jonathan Lehr]
- Fix library path warning. [Jonathan Lehr]
- Merge branch 'master' of https://github.com/AboutObjects/Modelmatic.
  [Jonathan Lehr]
- Rename modelmatic.podspec to Modelmatic.podspec. [Jonathan Lehr]
- Updated copyright. [Jonathan Lehr]
- Changed capitalization. [Jonathan Lehr]
- Move xcscheme to workspace. [Jonathan Lehr]
- Switch to Swift 2.3. [Jonathan Lehr]
- Switch to iPhone 6s simulator. [Jonathan Lehr]
- Pbxproj cleanup. [Jonathan Lehr]
- Configure Swift version in Podfile. [Jonathan Lehr]
- Disable ‘Legacy Swift Language Version’ [Jonathan Lehr]
- Add xcsheme. [Jonathan Lehr]
- Revert deployment target. [Jonathan Lehr]
- Update build target. [Jonathan Lehr]
- Update travis and xcodeproj settings. [Jonathan Lehr]
- Changed summary. [Jonathan Lehr]
- Remove ‘v’ from version tag. [Jonathan Lehr]


0.1.0 (2016-08-05)
------------------
- Update version number. [Jonathan Lehr]
- Add Cocoapod-based Xcode project. [Jonathan Lehr]
- Update AO link. [Jonathan Lehr]
- Fixed image height. [Jonathan Lehr]
- Image size. [Jonathan Lehr]
- Change image spec. [Jonathan Lehr]
- Reduce image size. [Jonathan Lehr]
- Update README text. [Jonathan Lehr]
- Add project icon. [Jonathan Lehr]
- Update README. [Jonathan Lehr]
- Initial commit. [Jonathan Lehr]


