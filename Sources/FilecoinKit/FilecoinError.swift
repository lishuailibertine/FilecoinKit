//
//  File.swift
//  
//
//  Created by li shuai on 2022/8/10.
//

import Foundation

public enum FilecoinTransactionError: Error, LocalizedError {
    case invalidSignature
    case invalidParams
    case otherError(message: String)
    public var errorDescription: String? {
        switch self {
        case .invalidSignature:
            return "invalidSignature"
        case .invalidParams:
            return "invalidParams"
        case .otherError(let message):
            return "\(message)"
        }
    }
}
