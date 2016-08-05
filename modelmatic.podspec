#
# Be sure to run `pod lib lint modelmatic.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'modelmatic'
  s.version          = 'v0.1.0'
  s.summary          = 'Adds automatic JSON serialization/deserialization to Swift model objects'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Modelmatic automates your app's model layer. It serializes model objects to JSON, and deserializes model objects from JSON, based on metadata you provide by configuring a Core Data model describing your model's entities, attributes, and relationships.

Modelmatic allows you to specify custom mappings between the names of JSON data elements and the names of corresponding properties of your model objects. The framework also automatically applies any value transformers (instances of `NSValueTransformer` subclasses) you specify in your model.
                       DESC

  s.homepage         = 'https://github.com/AboutObjects/modelmatic'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jonathan Lehr' => 'jonathan@aboutobjects.com' }
  s.source           = { :git => 'https://github.com/AboutObjects/modelmatic.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/aboutobjects'

  s.ios.deployment_target = '8.0'

  s.source_files = 'modelmatic/Classes/**/*'
  
  # s.resource_bundles = {
  #   'modelmatic' => ['modelmatic/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
