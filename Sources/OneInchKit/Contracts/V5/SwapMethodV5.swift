import Foundation
import BigInt
import EvmKit

class SwapMethodV5: ContractMethod {
    static let methodSignature = "swap(address,(address,address,address,address,uint256,uint256,uint256),bytes,bytes)"

    let caller: Address
    let swapDescription: SwapDescription
    let permit: Data
    let data: Data

    init(caller: Address, swapDescription: SwapDescription, permit: Data, data: Data) {
        self.caller = caller
        self.swapDescription = swapDescription
        self.permit = permit
        self.data = data

        super.init()
    }

    override var methodSignature: String { SwapMethodV5.methodSignature }

    override var arguments: [Any] {
        [caller, swapDescription, permit, data]
    }

    struct SwapDescription {
        let srcToken: Address
        let dstToken: Address
        let srcReceiver: Address
        let dstReceiver: Address
        let amount: BigUInt
        let minReturnAmount: BigUInt
        let flags: BigUInt
    }

}
