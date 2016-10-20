//
// Copyright (C) 2016 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation

private let handled = "ModelmaticRequestHandled"
private let handledKey = handled + "Key"
private let resourceKey = "resource" as NSString

// MARK: - NSInputStream
extension InputStream
{
    func data() -> Data? {
        let data = NSMutableData()
        var buf = [UInt8](repeating: 0, count: 4096)
        while hasBytesAvailable {
            let length = read(&buf, maxLength: buf.count)
            if length > 0 {
                data.append(buf, length: length)
            }
        }
        return data as Data
    }
}

// MARK: NSURLProtocol
class HttpSessionProtocol: URLProtocol, URLSessionTaskDelegate, URLSessionDataDelegate
{
    var session: Foundation.URLSession!
    var data: NSMutableData?
    
    lazy var serialQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        let mutableRequest = (request as NSURLRequest).mutableCopy()
        (mutableRequest as AnyObject).setValue(handled, forHTTPHeaderField: handledKey)
        super.init(request: mutableRequest as! URLRequest, cachedResponse: cachedResponse, client: client)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        let isHttpRequest = request.url?.scheme?.caseInsensitiveCompare("http") == .orderedSame
        guard let handledField: String = request.value(forHTTPHeaderField: handledKey) else {
            return true
        }
        return isHttpRequest && handledField != handled
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
}

extension HttpSessionProtocol
{
    func loadData(_ url: URL) {
        if let data = NSMutableData(contentsOf: url) {
            self.data = data
            return
        }
        guard let fileName = request.url?.parameterValue(resourceKey),
            let bundleUrl = URL.bundleDirectoryURL(forFileName: fileName, type: "json") else { return }
        self.data = NSMutableData(contentsOf: bundleUrl)
    }
    
    func loadFile(_ url: URL) {
        serialQueue.isSuspended = true
        serialQueue.addOperation { self.loadData(url) }
        serialQueue.addOperation { self.finishLoading() }
        serialQueue.isSuspended = false
    }
    
    func save(_ data: Data?, url: URL) {
        guard let data = data else { print("WARNING: data was nil"); return }
        try? data.write(to: url, options: [.atomic])
    }
    
    override func startLoading()
    {
        guard let fileName = request.url?.parameterValue(resourceKey) else { print("WARNING: resource (filename) is nil"); return }
        var fileUrl: URL? = URL.libraryDirectoryURL(forFileName: fileName, type: "json")
        if fileUrl == nil {
            fileUrl = URL.bundleDirectoryURL(forFileName: fileName, type: "json")
            if fileUrl == nil {
                print("WARNING: Unable to find file \(fileName)")
                let task = session.dataTask(with: request) { data, response, error in
                    if let d = data {
                        self.notifyClient(data: d, response: response!, error: error)
                    }
                }
                task.resume(); return
            }
        }
        
        if let httpMethod: String = request.httpMethod, httpMethod == "POST" || httpMethod == "PUT" {
            guard let stream = request.httpBodyStream else { print("WARNING: Stream is empty"); return }
            stream.open()
            save(stream.data(), url: fileUrl!)
        }
        loadFile(fileUrl!)
    }
    
    func notifyClient(data: Data, response: URLResponse, error: Error?) {
        guard error == nil else { client?.urlProtocol(self, didFailWithError: error!); return }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    func finishLoading()
    {
        guard let data = data, let url = request.url,
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
                client?.urlProtocol(self, didFailWithError: NSError(domain: "ModelmaticNetworkDomain", code: 42, userInfo: nil))
                return
        }
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        client?.urlProtocol(self, didLoad: data as Data)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        serialQueue.cancelAllOperations()
        data = nil
    }
}

// MARK: - NSURLSessionTaskDelegate
extension HttpSessionProtocol
{
    func urlSession(session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        data = nil
    }
}

// MARK: - NSURLSessionDataDelegate
extension HttpSessionProtocol
{
    func URLSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: NSData) {
        data.enumerateBytes { bytes, byteRange, stop in
            self.data?.append(bytes, length: byteRange.length)
        }
    }
}

