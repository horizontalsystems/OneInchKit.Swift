# OneInchKit.Swift

`OneInchKit.Swift` is an extension to `EvmKit.Swift`, that wraps interactions with [`1Inch API`](https://docs.1inch.io/docs/aggregation-protocol/api/swagger/).

## Usage

### Initialization

```swift
import EvmKit
import OneInchKit
import HdWalletKit

let evmKit = try Kit.instance(
	address: try EvmKit.Address(hex: "0x..user..address.."),
	chain: .ethereum,
	rpcSource: .ethereumInfuraWebsocket(projectId: "...", projectSecret: "..."),
	transactionSource: .ethereumEtherscan(apiKey: "..."),
	walletId: "unique_wallet_id",
	minLogLevel: .error
)

let swapKit = OneInchKit.Kit.instance(evmKit: evmKit)

// Decorators are needed to detect and decorate transactions as `1Inch` transactions
OneInchKit.Kit.addDecorators(to: evmKit)
```

### Sample code to get swap data from 1Inch API, sign it and send to RPC node

```swift
// Get Signer object
let seed = Mnemonic.seed(mnemonic: ["mnemonic", "words", ...])!
let signer = try Signer.instance(seed: seed, chain: .ethereum)

// Sample swap data
let tokenFromAddress = try! EvmKit.Address(hex: "0x..from..token..address")
let tokenToAddress = try! EvmKit.Address(hex: "0x..to..token..address")
let amount = BigUInt("100000000000000000")
let gasPrice = GasPrice.legacy(gasPrice: 50_000_000_000)

// Get Swap object, evaluated transaction data by 1Inch aggregator
let swapDataSingle: Single<Swap> = swapKit.swapSingle(
    fromToken: tokenFromAddress,
    toToken: tokenToAddress,
    amount: amount,
    slippage: 1,
    protocols: nil,
    recipient: nil,
    gasPrice: gasPrice,
    burnChi: nil,
    complexityLevel: nil,
    connectorTokens: nil,
    allowPartialFill: nil,
    gasLimit: nil,
    mainRouteParts: nil,
    parts: nil
)
            
// Generate a raw transaction
let rawTransactionSingle = swapDataSingle.flatMap { swap in
    let tx = swap.transaction
    let transactionData = EvmKit.TransactionData(to: tx.to, value: tx.value, input: tx.data)

    return evmKit.rawTransaction(transactionData: transactionData, gasPrice: gasPrice, gasLimit: tx.gasLimit)
}

let sendSingle = rawTransactionSingle.flatMap { rawTransaction in
    // Sign the transaction
    let signature = try signer.signature(rawTransaction: rawTransaction)
    
    // Send the transaction to RPC node
    return evmKit.sendSingle(rawTransaction: rawTransaction, signature: signature)
}

let disposeBag = DisposeBag()

sendSingle
    .subscribe(
        onSuccess: { fullTransaction in
            let transaction = fullTransaction.transaction
            print("Transaction sent: \(transaction.hash.hs.hexString)")
        }, onError: { error in
            print("Send failed: \(error)")
        }
    )
    .disposed(by: disposeBag)
```

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/horizontalsystems/OneInchKit.Swift.git", .upToNextMajor(from: "1.0.0"))
]
```

## License

The `OneInchKit.Swift` toolkit is open source and available under the terms of the [MIT License](https://github.com/horizontalsystems/ethereum-kit-ios/blob/master/LICENSE).

