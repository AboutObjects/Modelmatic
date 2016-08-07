# Modelmatic

Adds automatic JSON serialization/deserialization to Swift model objects.

[![CI Status](http://img.shields.io/travis/JonathanLehr/modelmatic.svg?style=flat)](https://travis-ci.org/JonathanLehr/Modelmatic)
[![Version](https://img.shields.io/cocoapods/v/modelmatic.svg?style=flat)](http://cocoapods.org/pods/Modelmatic)
[![License](https://img.shields.io/cocoapods/l/modelmatic.svg?style=flat)](http://cocoapods.org/pods/Modelmatic)
[![Platform](https://img.shields.io/cocoapods/p/modelmatic.svg?style=flat)](http://cocoapods.org/pods/Modelmatic)

Modelmatic automates your app's model layer. It enables model objects to be deserialized from JSON and serialized to JSON, based on metadata you provide by configuring a Core Data model that describes your model's entities, attributes, and relationships.

Modelmatic allows you to specify custom mappings between the names of JSON data elements and the names of corresponding properties of your model objects. The framework also automatically applies any value transformers (instances of `NSValueTransformer` subclasses) you specify in your model.

<img src="robo-small.png" height=320/>

*Image courtesy Christopher T. Howlett, the Noun Project*


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* Swift 2.3 and iOS 8.3 (or greater)
* Core Data (CoreData.framework)

## Installation

Modelmatic is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Modelmatic"
```

## Author

Jonathan Lehr, jonathan@aboutobjects.com

## License

Modelmatic is available under the MIT license. See the LICENSE file for more info.
