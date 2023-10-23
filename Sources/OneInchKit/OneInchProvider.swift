import Foundation
import BigInt
import EvmKit
import HsToolKit
import Alamofire

class OneInchProvider {
    private static let notEnoughEthErrors = [
        "Try to leave the buffer of ETH for gas",
        "you may not have enough ETH balance for gas fee",
        "Not enough ETH balance",
        "insufficient funds for transfer"
    ]

    private let networkManager: NetworkManager
    private let chain: Chain

    private var url: String { "https://api.1inch.dev/swap/" }
    private var headers: HTTPHeaders?

    init(networkManager: NetworkManager, chain: Chain, apiKey: String) {
        self.networkManager = networkManager
        self.chain = chain

        headers = HTTPHeaders([HTTPHeader.authorization(bearerToken: apiKey)])
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

    func quote(fromToken: Address, toToken: Address, amount: BigUInt, protocols: String? = nil, gasPrice: GasPrice? = nil, complexityLevel: Int? = nil,
               connectorTokens: String? = nil, gasLimit: Int? = nil, mainRouteParts: Int? = nil, parts: Int? = nil,
               includeTokensInfo: Bool = true, includeProtocols: Bool = true, includeGas: Bool = true
    ) async throws -> Quote {
       var parameters = params(dictionary:
       [
           "src": fromToken,
           "dst": toToken,
           "amount": amount.description,
           "protocols": protocols,
           "connectorTokens": connectorTokens,
           "complexityLevel": complexityLevel,
           "gasLimit": gasLimit,
           "mainRouteParts": mainRouteParts,
           "parts": parts,
           "includeTokensInfo": includeTokensInfo,
           "includeProtocols": includeProtocols,
           "includeGas": includeGas
       ])

        switch gasPrice {
        case .legacy(let legacyGasPrice):
            parameters["gasPrice"] = legacyGasPrice
        case .eip1559(let maxFeePerGas, let maxPriorityFeePerGas):
            parameters["maxFeePerGas"] = maxFeePerGas
            parameters["maxPriorityFeePerGas"] = maxPriorityFeePerGas
        case .none: ()
        }

        do {
            let json = try await networkManager.fetchJson(url: url + "v5.2/\(chain.id)/quote", method: .get, parameters: parameters, headers: headers, responseCacherBehavior: .doNotCache)

            guard let map = json as? [String: Any] else {
                throw ResponseError.invalidJson
            }

            return try QuoteMapper.quote(map: map)
        } catch {
            if let responseError = error as? NetworkManager.ResponseError,
               let dictionary = responseError.json as? [String: Any],
               let message = dictionary["message"] as? String,
               message.contains("insufficient liquidity") {
                throw Kit.QuoteError.insufficientLiquidity
            }

            throw error
        }
    }

    func swap(fromToken: String, toToken: String, amount: BigUInt, fromAddress: String, slippage: Decimal, referrer: String? = nil, protocols: String? = nil,
              recipient: String? = nil, gasPrice: GasPrice? = nil, burnChi: Bool? = nil, complexityLevel: Int? = nil, connectorTokens: String? = nil,
              allowPartialFill: Bool? = nil, gasLimit: Int? = nil, mainRouteParts: Int? = nil, parts: Int? = nil,
              includeTokensInfo: Bool = true, includeProtocols: Bool = true, includeGas: Bool = true
    ) async throws -> Swap {
       var parameters = params(dictionary:
       [
           "src": fromToken,
           "dst": toToken,
           "amount": amount.description,
           "from": fromAddress,
           "slippage": slippage,
           "referrer": referrer,
           "protocols": protocols,
           "receiver": recipient,
           "burnChi": burnChi,
           "complexityLevel": complexityLevel,
           "connectorTokens": connectorTokens,
           "allowPartialFill": allowPartialFill,
           "gasLimit": gasLimit,
           "mainRouteParts": mainRouteParts,
           "parts": parts,
           "includeTokensInfo": includeTokensInfo,
           "includeProtocols": includeProtocols,
           "includeGas": includeGas
       ])

        switch gasPrice {
        case .legacy(let legacyGasPrice):
            parameters["gasPrice"] = legacyGasPrice
        case .eip1559(let maxFeePerGas, let maxPriorityFeePerGas):
            parameters["maxFeePerGas"] = maxFeePerGas
            parameters["maxPriorityFeePerGas"] = maxPriorityFeePerGas
        case .none: ()
        }

        do {
            let json = try await networkManager.fetchJson(url: url + "v5.2/\(chain.id)/swap", method: .get, parameters: parameters, headers: headers, responseCacherBehavior: .doNotCache)

            guard let map = json as? [String: Any] else {
                throw ResponseError.invalidJson
            }

            return try SwapMapper.swap(map: map)
        } catch {
            if let responseError = error as? NetworkManager.ResponseError,
               let dictionary = responseError.json as? [String: Any],
               let message = dictionary["message"] as? String {
                if Self.notEnoughErrorContains(in: message) {
                    throw Kit.SwapError.notEnough
                } else if message.contains("cannot estimate") {
                    throw Kit.SwapError.cannotEstimate
                }
            }

            throw error
        }
    }

}

extension OneInchProvider {

    public enum ResponseError: Error {
        case invalidJson
    }

}
