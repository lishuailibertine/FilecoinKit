//
//  FilecoinKeypair.swift
//  FilecoinDemo
//
//  Created by li shuai on 2022/6/8.
//

import Foundation
import CryptoSwift
import Blake2
import Secp256k1Swift
import BIP32Swift

public enum FilecoinKeypairError: Error {
    case invalidSeed
    case invalidPrivateData
    case signError
}
public protocol FilecoinKeypair {
    var privateData: Data { get }
    var publicData: Data { get }
    init(seed: Data) throws
    init(privateData: Data) throws
    func sign(message: Data) throws -> Data
}
public struct FilecoinSecpKeypair: FilecoinKeypair {
    public var privateData: Data
    public var publicData: Data
    public static let PATH: String = "m/44'/461'/0'/0/0"
    public init(seed: Data) throws {
        guard let node = HDNode(seed: seed), let treeNode = node.derive(path: FilecoinSecpKeypair.PATH) else {
            throw FilecoinKeypairError.invalidSeed
        }
        guard let privateKey = treeNode.privateKey else {
            throw FilecoinKeypairError.invalidSeed
        }
        try self.init(privateData: privateKey)
    }
    public init(privateData: Data) throws {
        self.privateData = privateData
        guard let publicKey = SECP256K1.privateToPublic(privateKey: privateData, compressed: false) else {
            throw FilecoinKeypairError.invalidSeed
        }
        self.publicData = publicKey
    }
    public func sign(message: Data) throws -> Data {
        let hash = try Blake2.hash(.b2b, size: 32, data: message, key: nil)
        let signedData = SECP256K1.signForRecovery(hash: hash, privateKey: privateData, useExtraVer: false)
        guard let signData = signedData.serializedSignature else {
            throw FilecoinKeypairError.signError
        }
        debugPrint("signData \(signData.toHexString())")
        return signData
    }
}
