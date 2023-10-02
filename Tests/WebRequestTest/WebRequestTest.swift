//
//  WebRequestTest.swift
//
//
//  Created by Tomasz KUCHARSKI on 11/09/2023.
//

import XCTest
@testable import WebRequest

final class WebRequestTest: XCTestCase {
    func testGet() throws {
        struct SampleDto: Codable {
            let id: Int
            let title: String
            let body: String
        }
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            WebRequest<SampleDto>.get(url: "https://jsonplaceholder.typicode.com/todos/1") {
                print("\($0)")
            }

            let response: WebRequest<SampleDto> = .get(url: "https://jsonplaceholder.typicode.com/todos/1")
            print("\(response)")
            sem.signal()
        }
        sem.wait(timeout: .now() + 4)
    }
}
