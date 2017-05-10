Pod::Spec.new do |s|
    s.name             = 'Modelmatic'
    s.version          = '0.6.2'
    s.summary          = 'JSON serialization and deserialization for Swift model objects.'
    s.description      = <<-DESC
    Modelmatic adds JSON serialization and deserialization behavior to Swift model objects so that you don't have to. It allows you to take advantage of Xcode's built-in Core Data modeling tool to define mappings between object properties and JSON attributes, allowing you to seamlessly model relationships.
    DESC
    s.homepage         = 'https://github.com/AboutObjects/Modelmatic'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Jonathan Lehr' => 'jlehr@aboutobjects.com' }
    s.source           = { :git => 'https://github.com/AboutObjects/Modelmatic.git', :tag => s.version.to_s }
    s.ios.deployment_target = '10.0'
    s.source_files = 'Modelmatic/Classes/**/*'
    s.frameworks = 'CoreData'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
end
