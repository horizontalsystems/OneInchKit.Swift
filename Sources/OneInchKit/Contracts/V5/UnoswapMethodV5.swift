import Foundation
import BigInt
import EvmKit

// This method assumes that recipient is always the initiator of the transaction

class UnoswapMethodV5: ContractMethod {
    static let methodSignature = "unoswap(address,uint256,uint256,uint256[])"

    let srcToken: Address
    let amount: BigUInt
    let minReturn: BigUInt
    let params: [BigUInt]

    init(srcToken: Address, amount: BigUInt, minReturn: BigUInt, params: [BigUInt]) {
        self.srcToken = srcToken
        self.amount = amount
        self.minReturn = minReturn
        self.params = params

        super.init()
    }

    override var methodSignature: String { UnoswapMethodV5.methodSignature }

    override var arguments: [Any] {
        [srcToken, amount, minReturn, params]
    }

}
