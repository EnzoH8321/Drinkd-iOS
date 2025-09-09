//
//  NetworkClientMock.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 9/9/25.
//

import Testing
import Foundation

struct MockResponse {
  let statusCode: Int
  let body: Data
}

class MockNetworkClient {
  let urlSession: URLSession
  let baseURL: URL = URL(string: "https://practicalios.dev/")!

  init(urlSession: URLSession) {
    self.urlSession = urlSession
  }

//  func fetchPosts() async throws -> [Post] {
//    let url = baseURL.appending(path: "posts")
//    let (data, _) = try await urlSession.data(from: url)
//
//    return try JSONDecoder().decode([Post].self, from: data)
//  }
//
//  func createPost(withContents contents: String) async throws -> Post {
//    let url = baseURL.appending(path: "create-post")
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    let body = ["contents": contents]
//    request.httpBody = try JSONEncoder().encode(body)
//
//    let (data, _) = try await urlSession.data(for: request)
//
//    return try JSONDecoder().decode(Post.self, from: data)
//  }
}

class NetworkClientProtocolMock: URLProtocol {

    static var responses: [URL: MockResponse] = [:]
     static var validators: [URL: (URLRequest) -> Bool] = [:]
     static let queue = DispatchQueue(label: "NetworkClientURLProtocol")

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    static func register(
        response: MockResponse, requestValidator: @escaping (URLRequest) -> Bool, for url: URL
      ) {
        queue.sync {
          responses[url] = response
          validators[url] = requestValidator
        }
      }

    override func startLoading() {

        guard let client = self.client,
              let requestURL = self.request.url,
              let validator = NetworkClientProtocolMock.validators[requestURL],
              let response = NetworkClientProtocolMock.responses[requestURL]
        else {
            Issue.record("Attempted to perform a URL Request that doesn't have a validator and/or response")
            return
        }

        // validate that the request is as expected
        #expect(validator(self.request))

        // construct our response object
        guard let httpResponse = HTTPURLResponse(
            url: requestURL,
            statusCode: response.statusCode, httpVersion: nil,
            headerFields: nil
        ) else {
            Issue.record("Not able to create an HTTPURLResponse")
            return
        }

        // receive response from the fake network
        client.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
        // inform the URLSession that we've "loaded" data
        client.urlProtocol(self, didLoad: response.body)
        // complete the request
        client.urlProtocolDidFinishLoading(self)
    }

    
}
