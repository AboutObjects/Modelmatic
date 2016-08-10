//
// Copyright (C) 2016 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation

private let handled = "ModelmaticRequestHandled"
private let handledKey = handled + "Key"
private let resourceKey = "resource"

// MARK: - NSInputStream
extension NSInputStream
{
    func data() -> NSData? {
        let data = NSMutableData()
        var buf = [UInt8](count: 4096, repeatedValue: 0)
        while hasBytesAvailable {
            let length = read(&buf, maxLength: buf.count)
            if length > 0 {
                data.appendBytes(buf, length: length)
            }
        }
        return data
    }
}

// MARK: NSURLProtocol
class HttpSessionProtocol: NSURLProtocol, NSURLSessionTaskDelegate, NSURLSessionDataDelegate
{
    var session: NSURLSession!
    var data: NSMutableData?
    
    lazy var serialQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override init(request: NSURLRequest, cachedResponse: NSCachedURLResponse?, client: NSURLProtocolClient?) {
        let mutableRequest = request.mutableCopy()
        mutableRequest.setValue(handled, forHTTPHeaderField: handledKey)
        super.init(request: mutableRequest as! NSURLRequest, cachedResponse: cachedResponse, client: client)
    }
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        let isHttpRequest = request.URL?.scheme.caseInsensitiveCompare("http") == .OrderedSame
        guard let handledField: String = request.valueForHTTPHeaderField(handledKey) else {
            return true
        }
        return isHttpRequest && handledField != handled
    }
    
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
}

extension HttpSessionProtocol
{
    func loadData(url: NSURL) {
        if let data = NSMutableData(contentsOfURL: url) {
            self.data = data
            return
        }
        guard let fileName = request.URL?.parameterValue(resourceKey),
            bundleUrl = NSURL.bundleDirectoryURL(forFileName: fileName, type: "json") else { return }
        self.data = NSMutableData(contentsOfURL: bundleUrl)
    }
    
    func loadFile(url: NSURL) {
        serialQueue.suspended = true
        serialQueue.addOperationWithBlock { self.loadData(url) }
        serialQueue.addOperationWithBlock { self.finishLoading() }
        serialQueue.suspended = false
    }
    
    func save(data: NSData?, url: NSURL) {
        guard let data = data else { print("WARNING: data was nil"); return }
        data.writeToURL(url, atomically: true)
    }
    
    override func startLoading()
    {
        guard let fileName = request.URL?.parameterValue(resourceKey) else { print("WARNING: resource (filename) is nil"); return }
        var fileUrl: NSURL? = NSURL.libraryDirectoryURL(forFileName: fileName, type: "json")
        if fileUrl == nil {
            fileUrl = NSURL.bundleDirectoryURL(forFileName: fileName, type: "json")
            if fileUrl == nil {
                print("WARNING: Unable to find file \(fileName)")
                let task = session.dataTaskWithRequest(request) { data, response, error in
                    self.notifyClient(data!, response: response!, error: error)
                }
                task.resume(); return
            }
        }
        
        if let httpMethod: String = request.HTTPMethod where httpMethod == "POST" || httpMethod == "PUT" {
            guard let stream = request.HTTPBodyStream else { print("WARNING: Stream is empty"); return }
            stream.open()
            save(stream.data(), url: fileUrl!)
        }
        loadFile(fileUrl!)
    }
    
    func notifyClient(data: NSData, response: NSURLResponse, error: NSError?) {
        guard error == nil else { client?.URLProtocol(self, didFailWithError: error!); return }
        client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .Allowed)
        client?.URLProtocol(self, didLoadData: data)
        client?.URLProtocolDidFinishLoading(self)
    }
    
    func finishLoading()
    {
        guard let data = data, url = request.URL,
            response = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: nil, headerFields: nil) else {
                client?.URLProtocol(self, didFailWithError: NSError(domain: "ModelmaticNetworkDomain", code: 42, userInfo: nil))
                return
        }
        
        client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .Allowed)
        client?.URLProtocol(self, didLoadData: data)
        client?.URLProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        serialQueue.cancelAllOperations()
        data = nil
    }
}

// MARK: - NSURLSessionTaskDelegate
extension HttpSessionProtocol
{
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        data = nil
    }
}

// MARK: - NSURLSessionDataDelegate
extension HttpSessionProtocol
{
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        data.enumerateByteRangesUsingBlock { bytes, byteRange, stop in
            self.data?.appendBytes(bytes, length: byteRange.length)
        }
    }
}

