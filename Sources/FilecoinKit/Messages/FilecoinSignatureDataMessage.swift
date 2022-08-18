//
//  File.swift
//  
//
//  Created by li shuai on 2022/8/10.
//

import Foundation

public struct FilecoinSignatureDataMessage: Encodable {
    public var type: FileCoinSignType
    public var data: String
    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case data = "Data"
    }
    public init(type: FileCoinSignType, data: String) {
        self.type = type
        self.data = data
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(type.rawValue), forKey: .type)
        try container.encode(data, forKey: .data)
    }
}
