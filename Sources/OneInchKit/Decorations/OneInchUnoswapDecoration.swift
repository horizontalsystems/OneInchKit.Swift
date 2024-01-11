import BigInt
import EvmKit
import Foundation

public class OneInchUnoswapDecoration: OneInchDecoration {
    public let tokenIn: Token
    public let tokenOut: Token?
    public let amountIn: BigUInt
    public let amountOut: Amount
    public let params: [Data]

    public init(contractAddress: Address, tokenIn: Token, tokenOut: Token?, amountIn: BigUInt, amountOut: Amount, params: [Data]) {
        self.tokenIn = tokenIn
        self.tokenOut = tokenOut
        self.amountIn = amountIn
        self.amountOut = amountOut
        self.params = params

        super.init(contractAddress: contractAddress)
    }

    override public func tags() -> [TransactionTag] {
        var tags = [TransactionTag]()

        tags.append(tag(token: tokenIn, type: .swap))
        tags.append(tag(token: tokenIn, type: .outgoing))

        if let tokenOut {
            tags.append(tag(token: tokenOut, type: .swap))
            tags.append(tag(token: tokenOut, type: .incoming))
        }

        return tags
    }
}
