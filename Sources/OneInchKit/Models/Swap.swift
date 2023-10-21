import Foundation
import BigInt

public struct Swap {
    public let fromToken: Token
    public let toToken: Token
    public let toTokenAmount: BigUInt
    public let route: [Any]
    public let transaction: SwapTransaction

    public init(fromToken: Token, toToken: Token, toTokenAmount: BigUInt, route: [Any], transaction: SwapTransaction) {
        self.fromToken = fromToken
        self.toToken = toToken
        self.toTokenAmount = toTokenAmount
        self.route = route
        self.transaction = transaction
    }

}

extension Swap: CustomStringConvertible {

    public var description: String {
        "[Swap {\nfromToken:\(fromToken.name) - \ntoToken:\(toToken.name); \ntoAmount: \(toTokenAmount.description) \ntx: \(transaction.description)]"
    }

}

extension Swap {

    public var amountOut: Decimal? {
        toTokenAmount.toDecimal(decimals: toToken.decimals)
    }

}
