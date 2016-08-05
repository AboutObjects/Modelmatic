# modelmatic

Adds automatic JSON serialization/deserialization to Swift model objects.

[![CI Status](http://img.shields.io/travis/JonathanLehr/modelmatic.svg?style=flat)](https://travis-ci.org/JonathanLehr/modelmatic)
[![Version](https://img.shields.io/cocoapods/v/modelmatic.svg?style=flat)](http://cocoapods.org/pods/modelmatic)
[![License](https://img.shields.io/cocoapods/l/modelmatic.svg?style=flat)](http://cocoapods.org/pods/modelmatic)
[![Platform](https://img.shields.io/cocoapods/p/modelmatic.svg?style=flat)](http://cocoapods.org/pods/modelmatic)

Modelmatic automates your app's model layer. It serializes model objects to JSON, and deserializes model objects from JSON, based on metadata you provide by configuring a Core Data model describing your model's entities, attributes, and relationships.

Modelmatic allows you to specify custom mappings between the names of JSON data elements and the names of corresponding properties of your model objects. The framework also automatically applies any value transformers (instances of `NSValueTransformer` subclasses) you specify in your model.

<img src="robo-small.png" height=320/>

*Image courtesy Christopher T. Howlett, the Noun Project*


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Modelmatic is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "modelmatic"
```

## Author

Jonathan Lehr, jonathan@aboutobjects.com

## License

Modelmatic is available under the MIT license. See the LICENSE file for more info.
