//
//  Decodable+extension.swift
//
//
//  Created by Tomasz KUCHARSKI on 08/09/2023.
//

import Foundation

extension Decodable {
    init(json: String) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: json.data(using: .utf8)!)
    }

    init(json: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: json)
    }
}
