import Foundation
import RxSwift
import BigInt
import EvmKit
import HsToolKit

class OneInchProvider {
    private static let notEnoughEthErrors = ["Try to leave the buffer of ETH for gas", "you may not have enough ETH balance for gas fee", "Not enough ETH balance", "insufficient funds for transfer"]
    private let networkManager: NetworkManager
    private let chain: Chain

    private var url: String { "https://unstoppable.api.enterprise.1inch.exchange/" }

    init(networkManager: NetworkManager, chain: Chain) {
        self.networkManager = networkManager
        self.chain = chain
    }

    private func params(dictionary: [String: Any?]) -> [String: Any] {
        var result = [String: Any]()

        dictionary.forEach { key, value in
                    if let value = value {
                        result[key] = value
                    }
                }

        return result
    }

    private static func notEnoughErrorContains(in message: String) -> Bool {
        for error in notEnoughEthErrors {
            if message.contains(error) { return true }
        }

        return false
    }

}

extension OneInchProvider {

    func quoteSingle(fromToken: Address,
                     toToken: Address,
                     amount: BigUInt,
                     protocols: String? = nil,
                     gasPrice: GasPrice? = nil,
                     complexityLevel: Int? = nil,
                     connectorTokens: String? = nil,
                     gasLimit: Int? = nil,
                     mainRouteParts: Int? = nil,
                     parts: Int? = nil) -> Single<Quote> {

       var parameters = params(dictionary:
       [
           "fromTokenAddress": fromToken,
           "toTokenAddress": toToken,
           "amount": amount.description,
           "protocols": protocols,
           "connectorTokens": connectorTokens,
           "complexityLevel": complexityLevel,
           "gasLimit": gasLimit,
           "mainRouteParts": mainRouteParts,
           "parts": parts,
       ])

        switch gasPrice {
        case .legacy(let legacyGasPrice):
            parameters["gasPrice"] = legacyGasPrice
        case .eip1559(let maxFeePerGas, let maxPriorityFeePerGas):
            parameters["maxFeePerGas"] = maxFeePerGas
            parameters["maxPriorityFeePerGas"] = maxPriorityFeePerGas
        case .none: ()
        }

        let mapper = QuoteMapper(tokenMapper: TokenMapper())
        return networkManager
                .single(url: url + "v5.0/\(chain.id)/quote", method: .get, parameters: parameters, mapper: mapper, responseCacherBehavior: .doNotCache)
                .catchError { error in
                    if case let .invalidResponse(_, data) = (error as? NetworkManager.RequestError),
                       let dictionary = data as? [String: Any],
                       let message = dictionary["message"] as? String {
                        if message.contains("insufficient liquidity") {
                            return Single.error(Kit.QuoteError.insufficientLiquidity)
                        }
                    }

                    return Single.error(error)
                }
    }

    func swapSingle(fromToken: String,
                     toToken: String,
                     amount: BigUInt,
                     fromAddress: String,
                     slippage: Decimal,
                     protocols: String? = nil,
                     recipient: String? = nil,
                     gasPrice: GasPrice? = nil,
                     burnChi: Bool? = nil,
                     complexityLevel: Int? = nil,
                     connectorTokens: String? = nil,
                     allowPartialFill: Bool? = nil,
                     gasLimit: Int? = nil,
                     mainRouteParts: Int? = nil,
                     parts: Int? = nil) -> Single<Swap> {

       var parameters = params(dictionary:
       [
           "fromTokenAddress": fromToken,
           "toTokenAddress": toToken,
           "amount": amount.description,
           "fromAddress": fromAddress,
           "slippage": slippage,
           "protocols": protocols,
           "destReceiver": recipient,
           "burnChi": burnChi,
           "complexityLevel": complexityLevel,
           "connectorTokens": connectorTokens,
           "allowPartialFill": allowPartialFill,
           "gasLimit": gasLimit,
           "mainRouteParts": mainRouteParts,
           "parts": parts,
       ])

        switch gasPrice {
        case .legacy(let legacyGasPrice):
            parameters["gasPrice"] = legacyGasPrice
        case .eip1559(let maxFeePerGas, let maxPriorityFeePerGas):
            parameters["maxFeePerGas"] = maxFeePerGas
            parameters["maxPriorityFeePerGas"] = maxPriorityFeePerGas
        case .none: ()
        }

        let tokenMapper = TokenMapper()
        let mapper = SwapMapper(tokenMapper: tokenMapper, swapTransactionMapper: SwapTransactionMapper(tokenMapper: tokenMapper))

        return networkManager
                .single(url: url + "v5.0/\(chain.id)/swap", method: .get, parameters: parameters, mapper: mapper, responseCacherBehavior: .doNotCache)
                .catchError { error in
                    if case let .invalidResponse(_, data) = (error as? NetworkManager.RequestError),
                       let dictionary = data as? [String: Any],
                       let message = dictionary["message"] as? String {
                        if Self.notEnoughErrorContains(in: message) {
                            return Single.error(Kit.SwapError.notEnough)
                        } else if message.contains("cannot estimate") {
                            return Single.error(Kit.SwapError.cannotEstimate)
                        }
                    }

                    return Single.error(error)
                }
    }

}
