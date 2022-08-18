//
//  File.swift
//  
//
//  Created by li shuai on 2022/8/10.
//

import Foundation
import Blake2
import CBORSwift

extension FilecoinSignatureMessage {
    
    @discardableResult
    public mutating func sign(keypair: FilecoinKeypair, type: FileCoinSignType) throws -> Data {
        let serializeData = try self.message.serialize()
        let cid = try FilecoinSignatureMessage.cid(data: Data(hex: serializeData.toHexString()))
        let signatureData = try keypair.sign(message: cid)
        self.signature = FilecoinSignatureDataMessage(type: type, data: signatureData.base64EncodedString())
        return signatureData
    }
    // 获取消息内容生成的cid 具体实现参考ipfs源码(目前使用的版本为v1)
    public static func cid(data: Data) throws -> Data {
        let code: UInt64 = 45600
        let codec: UInt64 = 113
        let hashData = try Blake2.hash(.b2b, size: 32, data: data, key: nil)
        let codeArray = putUVarInt(code)
        let hashLengthArray = putUVarInt(UInt64(hashData.count))
        var encodeDataArray = [UInt8]()
        codeArray.forEach {encodeDataArray.append($0)}
        hashLengthArray.forEach {encodeDataArray.append($0)}
        hashData.forEach { encodeDataArray.append($0)}
        
        var cidDataArray = [UInt8]()
        let startArray = putUVarInt(UInt64(1))
        let codecArray = putUVarInt(codec)
        startArray.forEach{cidDataArray.append($0)}
        codecArray.forEach{cidDataArray.append($0)}
        encodeDataArray.forEach{cidDataArray.append($0)}
        
        return Data(cidDataArray)
    }
}
