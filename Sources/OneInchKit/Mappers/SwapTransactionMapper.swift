import BigInt
import EvmKit

struct SwapTransactionMapper {

    static func swapTransaction(map: [String: Any]) throws -> SwapTransaction {
        guard let fromString = map["from"] as? String,
              let from = try? Address(hex: fromString),
              let toString = map["to"] as? String,
              let to = try? Address(hex: toString),
              let dataString = map["data"] as? String,
              let data = dataString.hs.hexData,
              let valueSting = map["value"] as? String,
              let value = BigUInt(valueSting, radix: 10),
              let gasLimit = map["gas"] as? Int else {
            throw ResponseError.invalidJson
        }

        let gasPrice: GasPrice

        if let gasPriceString = map["gasPrice"] as? String, let gasPriceInt = Int(gasPriceString) {
            gasPrice = .legacy(gasPrice: gasPriceInt)
        } else if let maxFeePerGasString = map["maxFeePerGas"] as? String, let maxFeePerGas = Int(maxFeePerGasString),
                  let maxPriorityFeePerGasString = map["maxPriorityFeePerGas"] as? String, let maxPriorityFeePerGas = Int(maxPriorityFeePerGasString) {
            gasPrice = .eip1559(maxFeePerGas: maxFeePerGas, maxPriorityFeePerGas: maxPriorityFeePerGas)
        } else {
            throw ResponseError.invalidJson
        }


        return SwapTransaction(
                from: from,
                to: to,
                data: data,
                value: value,
                gasPrice: gasPrice,
                gasLimit: gasLimit
        )
    }

}

extension SwapTransactionMapper {

    public enum ResponseError: Error {
        case invalidJson
    }

}
