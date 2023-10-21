import Foundation
import BigInt

public struct Quote {
    public let fromToken: Token
    public let toToken: Token
    public let toTokenAmount: BigUInt
    public let route: [Any]
    public let estimateGas: Int

    public init(fromToken: Token, toToken: Token, toTokenAmount: BigUInt, route: [Any], estimateGas: Int) {
        self.fromToken = fromToken
        self.toToken = toToken
        self.toTokenAmount = toTokenAmount
        self.route = route
        self.estimateGas = estimateGas
    }

}

extension Quote: CustomStringConvertible {

    public var description: String {
        "[Quote {fromToken:\(fromToken.name) - toToken:\(toToken.name); toAmount: \(toTokenAmount.description)]"
    }

}

extension Quote {

    public var amountOut: Decimal? {
        toTokenAmount.toDecimal(decimals: toToken.decimals)
    }

}
