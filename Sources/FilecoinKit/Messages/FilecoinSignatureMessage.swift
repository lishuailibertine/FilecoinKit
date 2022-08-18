//
//  File.swift
//  
//
//  Created by li shuai on 2022/8/10.
//

import Foundation
import BigInt
import CBORSwift
import Blake2

public struct FilecoinSignatureMessage: Encodable {
    public var message: FilecoinTransactionMessage
    public var signature: FilecoinSignatureDataMessage?
    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case signature = "Signature"
    }
    public init(message: FilecoinTransactionMessage, signature: FilecoinSignatureDataMessage? = nil) {
        self.message = message
        self.signature = signature
    }
}
