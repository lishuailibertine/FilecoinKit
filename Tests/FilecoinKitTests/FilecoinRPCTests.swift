import XCTest
import CryptoSwift
import BigInt

@testable import FilecoinKit

final class FilecoinRPCTests: XCTestCase {
    
    var rpc: FilecoinHttpRequest {
        var request = FilecoinHttpRequest.shared
        request.url = "nodel url"
        return request
    }
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }
    func test_balance() throws {
        let expectation = XCTestExpectation(description: #function)
        rpc.balance(with: "f1tdyrm5ibh2ea7n5p23cm22l4asn6yf4z2bvgi7a").done { balance in
            debugPrint("balance: \(balance)")
            expectation.fulfill()
        }.catch { error in
            XCTFail("get balance error: \(error)")
        }
        
        wait(for: [expectation], timeout: 10)
    }
    func test_nonce() throws {
        let expectation = XCTestExpectation(description: #function)
        rpc.nonce(with: "f1tdyrm5ibh2ea7n5p23cm22l4asn6yf4z2bvgi7a").done { nonce in
            debugPrint("nonce: \(nonce)")
            expectation.fulfill()
        }.catch { error in
            XCTFail("get nonce error: \(error)")
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func test_gasPremium() throws {
        let expectation = XCTestExpectation(description: #function)
        let gasPremiumModel = FileCoinGasPremium(sender: try FilecoinAddress(address: "f1tdyrm5ibh2ea7n5p23cm22l4asn6yf4z2bvgi7a"), gaslimit: 2200000)
        
        rpc.gasPremium(premiumModel: gasPremiumModel).done { gasPremium in
            debugPrint("gasPremium: \(gasPremium)")
            expectation.fulfill()
        }.catch { error in
            XCTFail("get gasPremium error: \(error)")
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func test_feeCap() throws {
        let expectation = XCTestExpectation(description: #function)
        let fromAddress = try FilecoinAddress(address: "f1bbrqqcry2dzskg6e3v55fdhuy36sbkvj3unjtwi")
        let toAddress = try FilecoinAddress(address: "f1i6bu37j2o2w5dvzdy2ufmtxj3rlvjudfcwzenly")
        let transactionMessage =  FilecoinTransactionMessage(to: toAddress, from: fromAddress, nonce: 70, value: BigInt(1), gasLimit: 1, gasFeeCap: BigInt(862398101), gasPremium: BigInt(102731))
        
        let feeCapModel = FileCoinFeeCap(msg: transactionMessage)
        rpc.feeCap(feeCapModel: feeCapModel).done { feeCap in
            debugPrint("feeCap: \(feeCap)")
            expectation.fulfill()
        }.catch { error in
            XCTFail("get feeCap error: \(error)")
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func test_gasLimit() throws {
        
        let expectation = XCTestExpectation(description: #function)
        let fromAddress = try FilecoinAddress(address: "f1j4zgyuxw6ybwreq4iavy2zxkbk4nmyqcztmhqhq")
        let toAddress = try FilecoinAddress(address: "f1j4zgyuxw6ybwreq4iavy2zxkbk4nmyqcztmhqhq")
        let transactionMessage =  FilecoinTransactionMessage(to: toAddress, from: fromAddress, nonce: 14, value: BigInt(0), gasLimit: 2200000, gasFeeCap: BigInt(1), gasPremium: BigInt(1))
        
        
        rpc.gasLimit(transactionMessage: transactionMessage).done { gasLimit in
            debugPrint("gasLimit: \(gasLimit)")
            expectation.fulfill()
        }.catch { error in
            XCTFail("get gasLimit error: \(error)")
        }
        wait(for: [expectation], timeout: 10)
        
    }
    
    func test_MessageGas() throws {
        
        let expectation = XCTestExpectation(description: #function)
        let fromAddress = try FilecoinAddress(address: "f1j4zgyuxw6ybwreq4iavy2zxkbk4nmyqcztmhqhq")
        let toAddress = try FilecoinAddress(address: "f1j4zgyuxw6ybwreq4iavy2zxkbk4nmyqcztmhqhq")
        let transactionMessage =  FilecoinTransactionMessage(to: toAddress, from: fromAddress, nonce: 2, value: BigInt(10), gasLimit:0, gasFeeCap: BigInt(0), gasPremium: BigInt(0))
        
        let messageGas = FileCoinMessageGas(msg: transactionMessage, messageSendSpec: nil, tipSetKey: [])
        rpc.messageGas(messageGas: messageGas).done { message in
            debugPrint("message: \(message)")
            expectation.fulfill()
        }.catch { error in
            XCTFail("get message gas error: \(error)")
        }
        wait(for: [expectation], timeout: 10)
        
    }
    
    func test_chainHead() throws {
        let expectation = XCTestExpectation(description: #function)
        rpc.chainHead().done { chainheader in
            debugPrint("chainheader: \(chainheader.baseFee())")
            expectation.fulfill()
        }.catch { error in
            XCTFail("get gasLimit error: \(error)")
        }
        wait(for: [expectation], timeout: 10)
    }
}
