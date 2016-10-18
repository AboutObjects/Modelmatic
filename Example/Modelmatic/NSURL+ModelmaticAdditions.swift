//
// Copyright (C) 2016 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation

extension URL
{
    func queryParameters() -> NSDictionary?
    {
        let dict = NSMutableDictionary()
        guard let params = query?.components(separatedBy: "&") else { return nil }
        for currString in params {
            let s = currString.components(separatedBy: "=")
            dict[s[0]] = s[1]
        }
        return dict
    }
    
    func parameterValue(_ key: NSString) -> String? {
        guard let dict = queryParameters(), let value = dict[key] else { return nil }
        return value as? String
    }
    
    static func documentDirectoryURL(forFileName fileName: String, type: String) -> URL? {
        let URLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return URLs.first?.appendingPathComponent(fileName).appendingPathExtension(type)
    }
    
    static func bundleDirectoryURL(forFileName fileName: String, type: String) -> URL? {
        return Bundle(for: AuthorObjectStore.self).url(forResource: fileName, withExtension: type)
    }
    
    static func libraryDirectoryURL(forFileName fileName: String, type: String) -> URL? {
        let URLs = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return URLs.first?.appendingPathComponent(fileName).appendingPathExtension(type)
    }
}


extension HTTPURLResponse {
    var valid: Bool { return statusCode == 200 }
}

extension NSDictionary
{
    class func dictionary(contentsOfPropertyListFile fileName: String) -> NSDictionary?
    {
        if  let URL = URL.documentDirectoryURL(forFileName: fileName, type: "plist"),
            let dict = NSDictionary(contentsOf: URL) {
            return dict
        }
        
        guard let URL = URL.bundleDirectoryURL(forFileName: fileName, type: "plist") else { return nil }
        return NSDictionary(contentsOf: URL)
    }
    
    class func dictionary(contentsOfJSONFile fileName: String) -> NSDictionary?
    {
        if let url = URL.documentDirectoryURL(forFileName: fileName, type: "json"),
            let dict = NSDictionary.dictionary(contentsOf: url) {
            return dict
        }
        
        guard let url = URL.bundleDirectoryURL(forFileName: fileName, type: "json") else { return nil }
        return NSDictionary.dictionary(contentsOf: url)
    }
}

