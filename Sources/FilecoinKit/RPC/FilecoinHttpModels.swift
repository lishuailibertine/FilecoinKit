//
//  FilecoinResponseModel.swift
//  FilecoinDemo
//
//  Created by li shuai on 2022/8/9.
//

import Foundation
import BigInt
/**
 GasEstimateGasPremium(
     ctx context.Context,
     nblocksincl uint64,
     sender address.Address,
     gaslimit int64,
     _ types.TipSetKey,
 )
 */
public struct FileCoinGasPremium: Encodable {
    typealias Params = Array
    public var nblocksincl: Int?
    public var sender: FilecoinAddress
    public var gaslimit: Int
    public var placeholder: String?
    
    public init(nblocksincl: Int? = 10, sender: FilecoinAddress, gaslimit: Int) {
        self.nblocksincl = nblocksincl
        self.sender = sender
        self.gaslimit = gaslimit
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(nblocksincl!)
        try container.encode(sender.address)
        try container.encode(gaslimit)
        try container.encode(placeholder)
    }    
}
/**
 GasEstimateFeeCap(ctx context.Context, msg *types.Message, maxqueueblks int64
 */

public struct FileCoinFeeCap: Encodable {
    public var msg: FilecoinTransactionMessage
    public var maxqueueblks: Int?
    public var placeholder: String?
    public init(msg: FilecoinTransactionMessage, maxqueueblks: Int? = 20) {
        self.msg = msg
        self.maxqueueblks = maxqueueblks
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(msg)
        try container.encode(maxqueueblks!)
        try container.encode(placeholder)
    }
}
/**
 https://github.com/filecoin-project/lotus/blob/517c0a53b15749f366f271edf6513f9253559678/api/v0api/full.go
 // MpoolPushMessage atomically assigns a nonce, signs, and pushes a message
     // to mempool.
     // maxFee is only used when GasFeeCap/GasPremium fields aren't specified
     //
     // When maxFee is set to 0, MpoolPushMessage will guess appropriate fee
     // based on current chain conditions
 */
public struct FileCoinMessageGas: Encodable {
    public struct MessageSendSpec: Encodable {
        public var maxFee: BigInt?
        enum CodingKeys: String, CodingKey {
            case maxFee = "MaxFee"
        }
        public init(maxFee: BigInt? = BigInt(0)){
            self.maxFee = maxFee
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(maxFee!.description, forKey: .maxFee)
        }
    }
    public var msg: FilecoinTransactionMessage
    public var messageSendSpec: MessageSendSpec?
    public var tipSetKey: [String?]
    public init(msg: FilecoinTransactionMessage, messageSendSpec: MessageSendSpec?, tipSetKey: [String?]) {
        self.msg = msg
        self.messageSendSpec = messageSendSpec
        self.tipSetKey = tipSetKey
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(msg)
        try container.encode(messageSendSpec ?? MessageSendSpec())
        try container.encode(tipSetKey)
    }
}

// response
public struct FilecoinChainHead: Codable {
    public let height: Int
    private enum CodingKeys: String, CodingKey{
        case height = "Height"
        case blocks = "Blocks"
    }
    public struct Block: Codable {
        public let miner: String
        public let parentBaseFee: String
        private enum CodingKeys: String, CodingKey{
            case parentBaseFee = "ParentBaseFee"
            case miner = "Miner"
        }
    }
    public let blocks: [Block]?
}
extension FilecoinChainHead {
    public func baseFee() -> String {
        guard let headerBlocks = blocks else {
            return "0"
        }
        let addBaseFee = headerBlocks.reduce(BigUInt(0)) { partialResult, block in
            return partialResult + (BigUInt(block.parentBaseFee) ?? BigUInt(0))
        }
        return (addBaseFee / BigUInt(headerBlocks.count)).description
    }
}

public struct FilecoinTxResult: Codable{
    public let txId: String
    private enum CodingKeys: String, CodingKey {
        case txId = "/"
    }
}
