//
//  FileCoinAddress.swift
//  FilecoinDemo
//
//  Created by li shuai on 2022/6/13.
//

import Foundation
import Blake2
import CryptoSwift
import Base32Swift

public enum FileCoinSignType: UInt8, Codable {
    case SECP256K1 = 1
    case BLS = 3
}
public enum FilecoinAddressError: Error{
    case invalidPubkeyData
    case invalidAddress
    case invalidPayload
}
public struct FilecoinAddress {
    public var payload: Data
    public var address: String
    public var type: FileCoinSignType
    static private(set) var secpPayloadSize: Int = 20
    static private(set) var blsPayloadSize: Int = 48
    static private(set) var secpAddressSize: Int = 41
    static private(set) var blsAddressSize: Int = 86
    static private(set) var secpPublicKeySize: Int = 65
    static private(set) var blsPublicKeySize: Int = 48
    
    public init(publicKey: Data) throws {
        try self.init(payload: try FilecoinAddress.payload(publicKey: publicKey))
    }
    public init(address: String) throws {
       try self.init(payload: try FilecoinAddress.payload(address: address))
    }
    public init(payload: Data) throws {
        self.payload = payload
        self.type = try FilecoinAddress.signType(payload: payload)
        self.address = try FilecoinAddress.toBase32Address(payload: payload, type: type)
    }
    public func addressStr() throws -> Data {
        let payload = try FilecoinAddress.payload(address: self.address)
        var dataA = [UInt8]()
        dataA.append(type.rawValue)
        payload.forEach {dataA.append($0)}
        return Data(dataA)
    }
    public static func payload(publicKey: Data) throws -> Data {
        let type = try FilecoinAddress.signType(publicKey: publicKey)
        let payload = type == .SECP256K1 ? try Blake2.hash(.b2b, size: 20, data: publicKey, key: nil):publicKey
        guard payload.count == secpPayloadSize || payload.count == blsPayloadSize else {
            throw FilecoinAddressError.invalidPubkeyData
        }
        return payload
    }
    
    public static func payload(address: String) throws -> Data {
        let type = try FilecoinAddress.signType(address: address)
        let startIndex = address.index(address.startIndex, offsetBy: 2)
        let encodeAddress = String(address[startIndex..<address.endIndex])
        guard let zhData = base32DecodeToData(encodeAddress) else {
            throw FilecoinAddressError.invalidAddress
        }
        var dataArray = [UInt8]()
        zhData.forEach{dataArray.append($0)}
        return type == .SECP256K1 ? zhData.subdata(in: 0..<secpPayloadSize):zhData.subdata(in: 0..<blsPayloadSize)
    }
    
    private static func signType(payload: Data) throws -> FileCoinSignType {
        guard payload.count == secpPayloadSize || payload.count == blsPayloadSize else {
            throw FilecoinAddressError.invalidPayload
        }
        return payload.count == secpPayloadSize ? .SECP256K1 : .BLS
    }
    
    private static func signType(address: String) throws -> FileCoinSignType {
        guard address.count == secpAddressSize || address.count == blsAddressSize else {
            throw FilecoinAddressError.invalidAddress
        }
        return address.count == secpAddressSize ? .SECP256K1 : .BLS
    }
    
    private static func signType(publicKey: Data) throws -> FileCoinSignType {
        guard publicKey.count == secpPublicKeySize || publicKey.count == blsPublicKeySize else {
            throw FilecoinAddressError.invalidPubkeyData
        }
        return publicKey.count == secpPublicKeySize ? .SECP256K1 : .BLS
    }
    
    private static func toBase32Address(payload: Data, type: FileCoinSignType) throws -> String {
        var newDataArray = [UInt8]()
        newDataArray.append(type.rawValue)
        payload.forEach{newDataArray.append($0)}
        
        var zhDataArray = [UInt8]()
        payload.forEach{zhDataArray.append($0)}
        let newDataHash = try Blake2.hash(.b2b, size: 4, data: Data(newDataArray), key: nil)
        newDataHash.forEach{zhDataArray.append($0)}
        
        var address = base32Encode(Data(zhDataArray)).lowercased()
        if address.contains("=") {
            address = address.replacingOccurrences(of: "=", with: "")
        }
        return "f" + "\(type.rawValue)" + address
    }
}
