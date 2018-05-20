//
//  Utils.swift
//  SerializationTests
//
//  Created by Taylor Griffin on 20/5/18.
//

import Foundation

extension Data {
    func toJSONObject() throws -> Any {
        return try JSONSerialization.jsonObject(with: self, options: .allowFragments)
    }
    
    func prettyJSONString() throws -> String {
        let json = try self.toJSONObject()
        let pretty = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        return String(data: pretty, encoding: .utf8)!
    }
}
