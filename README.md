# Modelmatic

A framework that allows you to use a Core Data model to define mappings between JSON data elements and properties of non-Core Data model objects.

[![Modelmatic Version][modelmatic-image]][modelmatic-url]

Modelmatic automates your app's model layer. It serializes model objects to JSON, and deserializes model objects from JSON, based on metadata you provide by configuring a Core Data model describing your model's entities, attributes, and relationships.

Modelmatic allows you to specify custom mappings between the names of JSON data elements and the names of corresponding properties of your model objects. The framework also automatically applies any value transformers (instances of `NSValueTransformer` subclasses) you specify in your model.

<img src="robo-small.png" height=320/>

*Image courtesy Christopher T. Howlett, the Noun Project*

## Installation

```sh
pod install modelmatic
```


## Usage example

A few motivating and useful examples of how your product can be used. Spice this up with code blocks and potentially more screenshots.

## Development setup

Describe how to install all development dependencies and how to run an automated test-suite of some kind. Potentially do this for multiple platforms.

```sh
make install
```

## Release History

* 0.0.1
    * Initial setup
    * ADD: LICENSE and README

## Meta

Jonathan Lehr – [@jlehr](https://twitter.com/jlehr) – info@aboutobjects.com

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/yourname/github-link](https://github.com/dbader/)

[modelmatic-image]: https://img.shields.io/badge/modelmatic-v0.1.0-orange.svg
[modelmatic-url]: http://blog.aboutobjects.com
