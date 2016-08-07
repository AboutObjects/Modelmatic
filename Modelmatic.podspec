#
# Be sure to run `pod lib lint Modelmatic.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'Modelmatic'
s.version          = '0.2.0'
s.summary          = 'JSON serialization and deserialization for Swift model objects.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
Modelmatic adds JSON serialization and deserialization behavior to Swift model objects so that you don't have to. It allows you to take advantage of Xcode's built-in Core Data modeling tool to define mappings between object properties and JSON attributes, allowing you to seamlessly model relationships.
DESC

s.homepage         = 'https://github.com/AboutObjects/Modelmatic'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Jonathan Lehr' => 'jlehr@aboutobjects.com' }
s.source           = { :git => 'https://github.com/AboutObjects/Modelmatic.git', :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

s.ios.deployment_target = '8.3'

s.source_files = 'Modelmatic/Classes/**/*'

# s.resource_bundles = {
#   'Modelmatic' => ['Modelmatic/Assets/*.png']
# }

# s.public_header_files = 'Pod/Classes/**/*.h'
s.frameworks = 'CoreData'
# s.dependency 'AFNetworking', '~> 2.3'

end
