# FilecoinKit
Filecoin swift package

## Features
* Account address generation and verification
* Support 'Secp256k1'

## Installation
### Swift Package Manager
Add .package(url:_:) to your Package.swift:
```Swift
dependencies: [
    .package(url: "https://github.com/lishuailibertine/FlowSwift", .branch("main")),
],
```
## Usage
```Swift
// Types of requested services currently supported
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
 
// keypair
 let keypair = try FilecoinSecpKeypair(privateData:  Data(base64Encoded: "aGwOA+9h9NBsZLHmrjdenKfiXT2RoMlxlDSVp+BG9Xc=")!)
 let address = try FilecoinAddress(publicKey: keypair.publicData)
 XCTAssertTrue(address.address == "f16n67k563rjncdk4jcrh5ei37z2j2fpxh4hqjula")
 
// address
 let address =  try FilecoinAddress(publicKey: Data(hex:  "04ec7653cc6517a6383aa49958683259d6540e01a663140d7b8ea1479ea7d90f82566e079e78bd451b03b5ce4911b4b4fed8bed8057cc8f7fae0bdcc234fe55d14"))
 XCTAssertTrue(address.address == "f1tdyrm5ibh2ea7n5p23cm22l4asn6yf4z2bvgi7a")
        
 let address1 = try FilecoinAddress(address: "f1tdyrm5ibh2ea7n5p23cm22l4asn6yf4z2bvgi7a")
 XCTAssertTrue(address1.payload.toHexString() == address.payload.toHexString())
 let address2 = try FilecoinAddress(payload: Data(hex: "98f11675013e880fb7afd6c4cd697c049bec1799"))
 XCTAssertTrue(address2.address == address.address)
 XCTAssertTrue(address2.address == address1.address)
```
