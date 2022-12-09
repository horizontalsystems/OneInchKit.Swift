import Foundation
import BigInt
import EvmKit

class UnparsedSwapMethodsFactoryV5: IContractMethodsFactory {
    var methodId: Data { Data() }
    let methodIds: [Data] = [
        hexToData("0x84bd6d29"), // clipperSwap
        hexToData("0x093d4fa5"), // clipperSwapTo
        hexToData("0xc805a666"), // clipperSwapToWithPermit
        hexToData("0x62e238bb"), // fillOrder
        hexToData("0x3eca9c0a"), // fillOrderRFQ
        hexToData("0x9570eeee"), // fillOrderRFQCompact
        hexToData("0x5a099843"), // fillOrderRFQTo
        hexToData("0x70ccbd31"), // fillOrderRFQToWithPermit
        hexToData("0xe5d7bde6"), // fillOrderTo
        hexToData("0xd365c695"), // fillOrderToWithPermit
        hexToData("0xe449022e"), // uniswapV3Swap
        hexToData("0xfa461e33"), // uniswapV3SwapCallback
        hexToData("0xbc80f1a8"), // uniswapV3SwapTo
        hexToData("0x2521b930"), // uniswapV3SwapToWithPermit
        hexToData("0xf78dc253"), // unoswapTo
        hexToData("0x3c15fd91")  // unoswapToWithPermit

    ]

    func createMethod(inputArguments: Data) throws -> ContractMethod {
        UnparsedSwapMethodV5()
    }

    private static func uint8(_ s: String) -> UInt8 {
        UInt8(s, radix: 16) ?? 0
    }

    private static func hexToData(_ s: String) -> Data {
        var s = s.dropFirst(2)
        let n1 = s.prefix(2)
        s = s.dropFirst(2)
        let n2 = s.prefix(2)
        s = s.dropFirst(2)
        let n3 = s.prefix(2)
        let n4 = s.suffix(2)

        return Data([UInt8(n1, radix: 16) ?? 0, UInt8(n2, radix: 16) ?? 0, UInt8(n3, radix: 16) ?? 0, UInt8(n4, radix: 16) ?? 0])
    }

}
