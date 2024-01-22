import BigInt
import EvmKit
import Foundation
import HsToolKit

public class Kit {
    private let provider: OneInchProvider

    init(provider: OneInchProvider) {
        self.provider = provider
    }
}

public extension Kit {
    func quote(networkManager: NetworkManager, chain: Chain, fromToken: Address, toToken: Address, amount: BigUInt, protocols: String? = nil, gasPrice: GasPrice? = nil, complexityLevel: Int? = nil,
               connectorTokens: String? = nil, gasLimit: Int? = nil, mainRouteParts: Int? = nil, parts: Int? = nil) async throws -> Quote
    {
        try await provider.quote(
            networkManager: networkManager,
            chain: chain,
            fromToken: fromToken,
            toToken: toToken,
            amount: amount,
            protocols: protocols,
            gasPrice: gasPrice,
            complexityLevel: complexityLevel,
            connectorTokens: connectorTokens,
            gasLimit: gasLimit,
            mainRouteParts: mainRouteParts,
            parts: parts
        )
    }

    func swap(networkManager: NetworkManager, chain: Chain, receiveAddress: Address, fromToken: Address, toToken: Address, amount: BigUInt, slippage: Decimal, protocols: [String]? = nil, recipient: Address? = nil,
              gasPrice: GasPrice? = nil, burnChi: Bool? = nil, complexityLevel: Int? = nil, connectorTokens: [String]? = nil,
              allowPartialFill: Bool? = nil, gasLimit: Int? = nil, mainRouteParts: Int? = nil, parts: Int? = nil) async throws -> Swap
    {
        try await provider.swap(
            networkManager: networkManager,
            chain: chain,
            fromToken: fromToken.hex,
            toToken: toToken.hex,
            amount: amount,
            fromAddress: receiveAddress.hex,
            slippage: slippage,
            protocols: protocols?.joined(separator: ","),
            recipient: recipient?.hex,
            gasPrice: gasPrice,
            burnChi: burnChi,
            complexityLevel: complexityLevel,
            connectorTokens: connectorTokens?.joined(separator: ","),
            allowPartialFill: allowPartialFill,
            gasLimit: gasLimit,
            mainRouteParts: mainRouteParts,
            parts: parts
        )
    }
}

public extension Kit {
    static func instance(apiKey: String) -> Kit {
        Kit(provider: OneInchProvider(apiKey: apiKey))
    }

    static func addDecorators(to evmKit: EvmKit.Kit) {
        evmKit.add(methodDecorator: OneInchMethodDecorator(contractMethodFactories: OneInchContractMethodFactories.shared))
        evmKit.add(transactionDecorator: OneInchTransactionDecorator(address: evmKit.address))
    }

    static func routerAddress(chain: Chain) throws -> Address {
        switch chain.id {
        case 1, 10, 56, 100, 137, 250, 42161, 43114: return try Address(hex: "0x1111111254EEB25477B68fb85Ed929f73A960582")
        case 3, 4, 5, 42: return try Address(hex: "0x11111112542d85b3ef69ae05771c2dccff4faa26")
        default: throw UnsupportedChainError.noRouterAddress
        }
    }
}

public extension Kit {
    enum UnsupportedChainError: Error {
        case noRouterAddress
    }

    enum QuoteError: Error {
        case insufficientLiquidity
    }

    enum SwapError: Error {
        case notEnough
        case cannotEstimate
    }
}

public extension BigUInt {
    func toDecimal(decimals: Int) -> Decimal? {
        guard let decimalValue = Decimal(string: description) else {
            return nil
        }

        return decimalValue / pow(10, decimals)
    }
}
