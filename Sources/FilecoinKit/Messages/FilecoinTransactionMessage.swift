//
//  File.swift
//  
//
//  Created by li shuai on 2022/8/10.
//

import Foundation
import CBORSwift
import BigInt
import CryptoSwift

public struct FilecoinTransactionMessage: Codable {
    public var version: Int
    public var to: FilecoinAddress
    public var from: FilecoinAddress
    public var nonce: Int
    public var value: BigInt
    public var method: Int
    public var gasLimit: Int
    public var gasFeeCap: BigInt
    public var gasPremium: BigInt
    public var params: String?
    
    enum CodingKeys: String, CodingKey {
        case version = "Version"
        case to = "To"
        case from = "From"
        case nonce = "Nonce"
        case value = "Value"
        case method = "Method"
        case gasLimit = "GasLimit"
        case gasFeeCap = "GasFeeCap"
        case gasPremium = "GasPremium"
        case params = "Params"
    }
    public init(version: Int = 0, to: FilecoinAddress, from: FilecoinAddress, nonce: Int, value: BigInt, method: Int = 0, gasLimit: Int, gasFeeCap: BigInt, gasPremium: BigInt, params: String? = nil) {
        self.version = version
        self.to = to
        self.from = from
        self.nonce = nonce
        self.value = value
        self.method = method
        self.gasLimit = gasLimit
        self.gasPremium = gasPremium
        self.gasFeeCap = gasFeeCap
        self.params = params
    }
    public func serialize() throws -> Data {
        var messages = [Any]()
        messages.append(version)
        messages.append(try to.addressStr())
        messages.append(try from.addressStr())
        messages.append(nonce)
        messages.append(value.serialize())
        messages.append(gasLimit)
        messages.append(gasFeeCap.serialize())
        messages.append(gasPremium.serialize())
        messages.append(method)
        if params != nil {
            guard let paramData = Data(base64Encoded: params!, options: []) else {
                throw FilecoinTransactionError.invalidParams
            }
            messages.append(paramData)
        }
        let dataPackage = try CBOR.encodeAny(messages)
        let resultData = NSMutableData()
        resultData.append(Data(dataPackage))
        if  params == nil {
            resultData.append(Data([64]))
        }
        var number = 138
        resultData.replaceBytes(in: NSRange.init(location: 0, length: 1), withBytes: &number)
        return Data(bytes: resultData.bytes, count: resultData.count)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(to.address, forKey: .to)
        try container.encode(from.address, forKey: .from)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(value.description, forKey: .value)
        try container.encode(method, forKey: .method)
        try container.encode(gasLimit, forKey: .gasLimit)
        try container.encode(gasFeeCap.description, forKey: .gasFeeCap)
        try container.encode(gasPremium.description, forKey: .gasPremium)
        try container.encode(params ?? "", forKey: .params)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        let toAddress = try container.decode(String.self, forKey: .to)
        to = try FilecoinAddress(address: toAddress)
        let fromAddress = try container.decode(String.self, forKey: .from)
        from = try FilecoinAddress(address: fromAddress)
        nonce = try container.decode(Int.self, forKey: .nonce)
        let valueNumber = try container.decode(String.self, forKey: .value)
        value = BigInt(Int(valueNumber) ?? 0)
        gasLimit = try container.decode(Int.self, forKey: .gasLimit)
        let gasFeeCapNumber = try container.decode(String.self, forKey: .gasFeeCap)
        gasFeeCap = BigInt(Int(gasFeeCapNumber) ?? 0)
        let gasPremiumNumber = try container.decode(String.self, forKey: .gasPremium)
        gasPremium = BigInt(Int(gasPremiumNumber) ?? 0)
        method = try container.decode(Int.self, forKey: .method)
        params = try container.decode(String.self, forKey: .params)
    }
}
