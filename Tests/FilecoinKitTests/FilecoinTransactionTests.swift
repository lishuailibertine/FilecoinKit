//
//  FilecoinTransactionTests.swift
//  
//
//  Created by li shuai on 2022/8/10.
//

import XCTest
import BigInt
import CBORSwift
import Secp256k1Swift
import Blake2
import PromiseKit

@testable import FilecoinKit

class FilecoinTransactionTests: XCTestCase {
    var rpc: FilecoinHttpRequest {
        FilecoinHttpRequest.shared
    }
    func test_message() throws {
        
        let fromAddress = try FilecoinAddress(address: "f1mrttouiyjridjdemclofm3od2zzhx5ejrs4kmby")
        
        XCTAssertTrue(try fromAddress.addressStr().toHexString() ==  "0164673751184c50348c8c12dc566dc3d6727bf489")
        let toAddress = try FilecoinAddress(address: "f3xe53iffiezpdrpsmrfvi5v3btjgzgpudl7lpbfit5rfagqgrr4ks56gcu6gvpea7onay24ogoelmzc6dt42q")
        
        XCTAssertTrue(try toAddress.addressStr().toHexString() ==  "03b93bb414a8265e38be4c896a8ed7619a4d933e835fd6f09513ec4a0340d18f152ef8c2a78d57901f73418d71c67116cc")
        
        let transactionMessage =  FilecoinTransactionMessage(to: toAddress, from: fromAddress, nonce: 14, value: BigInt(100000000000000), gasLimit: 2200000, gasFeeCap: BigInt(862398101), gasPremium: BigInt(102731))
        
        XCTAssertTrue(try transactionMessage.serialize().toHexString() == "8a00583103b93bb414a8265e38be4c896a8ed7619a4d933e835fd6f09513ec4a0340d18f152ef8c2a78d57901f73418d71c67116cc550164673751184c50348c8c12dc566dc3d6727bf4890e47005af3107a40001a002191c0450033672695440001914b0040")
        
    }
    func test_cbor() throws {
        let bytes = try CBOR.encodeAny(BigInt(10000000000000).serialize())
        let data = Data(bytes: bytes, count: bytes.count)
        
        let bytes1 = try CBOR.encodeAny(BigUInt(10000000000000).serialize())
        let data1 = Data(bytes: bytes1, count: bytes1.count)
        XCTAssertTrue(data.toHexString() == "470009184e72a000")
        XCTAssertTrue(data1.toHexString() == "4609184e72a000")
    }
    func test_cid() throws {
        //message: 8a00583103b93bb414a8265e38be4c896a8ed7619a4d933e835fd6f09513ec4a0340d18f152ef8c2a78d57901f73418d71c67116cc550164673751184c50348c8c12dc566dc3d6727bf4890d47005af3107a40001a002191c0450042cd755f440001b0730040
        let cid = try FilecoinSignatureMessage.cid(data: Data(hex: "8a00583103b93bb414a8265e38be4c896a8ed7619a4d933e835fd6f09513ec4a0340d18f152ef8c2a78d57901f73418d71c67116cc550164673751184c50348c8c12dc566dc3d6727bf4890d470009184e72a0001a002191c0450050c7bbad440001b4dc0040")).toHexString()
        XCTAssertTrue(cid == "0171a0e402208e7ba85943a6c518254ac30b9da9fce76eea5c5ed121756d56e53f6484ecfa7b")
    }

}
