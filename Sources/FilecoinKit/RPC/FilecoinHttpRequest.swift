//
//  FilecoinRPC.swift
//  FilecoinDemo
//
//  Created by li shuai on 2022/6/17.
//

import Foundation
import PromiseKit
import Alamofire
import Secp256k1Swift

public struct FilecoinHttpRequest {
    public struct FilecoinResultError: Decodable {
        public var code: Int
        public var message: String
    }
    public struct FilecoinResult<T: Decodable>: Decodable {
        public var result: T?
        public var error: FilecoinResultError?
    }
    public enum FilecoinProviderType: String{
        case Balance = "WalletBalance"
        case Nonce = "MpoolGetNonce"
        case SendMessage = "MpoolPush"
        case MpoolPending = "MpoolPending"
        case ChainHead = "ChainHead"
        case GasEstimateGasLimit = "GasEstimateGasLimit"
        case GasEstimateGasPremium = "GasEstimateGasPremium"
        case GasEstimateFeeCap = "GasEstimateFeeCap"
        case MpoolPendingFilter = "MpoolPendingFilter"
        case GasEstimateMessageGas = "GasEstimateMessageGas"
    }
    public enum FilecoinProviderError: Error, LocalizedError {
        case invalidInfuraToken
        case invalidInfuraUrl
        public var errorDescription: String?{
            switch self {
            case .invalidInfuraToken:
                return "invalid InfuraToken"
            case .invalidInfuraUrl:
                return "invalid InfuraUrl"
            }
        }
    }
    enum FilecoinURL {
        case normal(url: String)
        case infura(url: String)
        func api() throws -> String {
            switch self {
            case .normal(let url):
                return url
            case .infura(let url):
                guard url.contains("@"), let urlStr = url.split(separator: "@").first else {
                    throw FilecoinProviderError.invalidInfuraUrl
                }
                return String(urlStr)
            }
        }
    }
    struct FilecoinRPCParam {
        var jsonrpc: String
        var id: Int
        var method: String
        var params: [Any]?
        
        init(method: FilecoinProviderType, jsonrpc: String = "2.0", id: Int = 1, params: [Any]?) {
            self.id = id
            self.method = "Filecoin.\(method.rawValue)"
            self.params = params
            self.jsonrpc = jsonrpc
        }
        var requestParams: Parameters{
            var requestParams = Parameters()
            requestParams["jsonrpc"] = jsonrpc
            requestParams["id"] = id
            requestParams["method"] = method
            if params != nil {
                requestParams["params"] = params
            }
            return requestParams
        }
    }
    public var url: String
    public var path: String?
    private var infuraToken: String?
    public static let shared = FilecoinHttpRequest()
    public init(url: String = "https://filecoin.YourOwnNode", path: String? = "/rpc/v0", infuraToken: String? = nil) {
        self.url = url
        self.path = path
        self.infuraToken = infuraToken
    }
    public func balance(with address: String) -> Promise<String> {
        return Promise { seal in
            POST(method: .Balance, parameters: [address]).done { (balance: String) in
                seal.fulfill(balance)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func nonce(with address: String) -> Promise<Int> {
        return Promise { seal in
            POST(method: .Nonce, parameters: [address]).done { (nonce: Int) in
                seal.fulfill(nonce)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    public func chainHead() -> Promise<FilecoinChainHead> {
        return Promise { seal in
            POST(method: .ChainHead).done { (head: FilecoinChainHead) in
                seal.fulfill(head)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    public func send(content signedMessage: FilecoinSignatureMessage) -> Promise<FilecoinTxResult> {
        return Promise { seal in
            let encoder = JSONEncoder()
            let data = try encoder.encode(signedMessage)
            let paramDic = try JSONSerialization.jsonObject(with: data, options: [])
            POST(method: .SendMessage, parameters: [paramDic]).done { (txResult: FilecoinTxResult) in
                seal.fulfill(txResult)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    public func gasPremium(premiumModel: FileCoinGasPremium) -> Promise<String> {
        return Promise { seal in
            let encoder = JSONEncoder()
            let data = try encoder.encode(premiumModel)
            let parameters = try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            POST(method: .GasEstimateGasPremium, parameters: parameters).done { (gasPremium: String) in
                seal.fulfill(gasPremium)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func feeCap(feeCapModel: FileCoinFeeCap) -> Promise<String> {
        return Promise { seal in
            let encoder = JSONEncoder()
            let data = try encoder.encode(feeCapModel)
            let parameters = try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            POST(method: .GasEstimateFeeCap, parameters: parameters).done { (cap: String) in
                seal.fulfill(cap)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func gasLimit(transactionMessage: FilecoinTransactionMessage) -> Promise<Int> {
        return Promise { seal in
            let encoder = JSONEncoder()
            let data = try encoder.encode(transactionMessage)
            let parameters = try JSONSerialization.jsonObject(with: data, options: [])
            POST(method: .GasEstimateGasLimit, parameters: [parameters, NSNull()]).done { (gaslimit: Int) in
                seal.fulfill(gaslimit)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    public func messageGas(messageGas: FileCoinMessageGas) -> Promise<FilecoinTransactionMessage> {
        return Promise { seal in
            let encoder = JSONEncoder()
            let data = try encoder.encode(messageGas)
            let parameters = try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            POST(method: .GasEstimateMessageGas, parameters: parameters).done { (message: FilecoinTransactionMessage) in
                seal.fulfill(message)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    private func headers() throws -> HTTPHeaders {
        var headers: HTTPHeaders = ["Content-type": "text/plain;charset=UTF-8"]
        // default
        headers.add(name: "Authorization", value: "Bearer Token")
        if let infuraToken = self.infuraToken {
            let project_id = String(url.split(separator: "@")[1])
            let infuraAuthStr = project_id + ":" + infuraToken
            guard let encodeAuthStr = infuraAuthStr.data(using: .utf8)?.base64EncodedString() else {
                throw FilecoinProviderError.invalidInfuraToken
            }
            headers.add(name: "Authorization", value: "Basic \(encodeAuthStr)")
        }
        return headers
    }
    
    private func POST<Response: Decodable>(method: FilecoinProviderType, parameters: [Any]? = nil) -> Promise<Response> {
        return Promise { seal in
            
            let param = FilecoinRPCParam(method: method, params: parameters)
            let api: String = url.contains("@") ? try FilecoinURL.infura(url: url).api() : try FilecoinURL.normal(url: url).api()
            AF.request("\(api)\(path ?? "")", method: .post, parameters: param.requestParams, encoding: JSONEncoding.default, headers: try headers()).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let result = try JSONDecoder().decode(FilecoinResult<Response>.self, from: data)
                        if let res = result.result {
                            seal.fulfill(res)
                        } else if let err = result.error {
                            seal.reject(FilecoinTransactionError.otherError(message: "\(err.code):\(err.message)"))
                        } else {
                            seal.reject(FilecoinTransactionError.otherError(message: "Unknown error"))
                        }
                    } catch let e {
                        seal.reject(e)
                    }
                case .failure(let e):
                    seal.reject(e)
                }
            }
        }
    }
}
