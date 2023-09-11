//
//  WebRequestTest.swift
//  
//
//  Created by Tomasz KUCHARSKI on 11/09/2023.
//

import XCTest
@testable import Template

final class WebRequestTest: XCTestCase {
    func testVariableNotAssigned() throws {
        let template = Template(raw: "{number}empty")
        XCTAssertEqual("empty", template.output)
    }
}
