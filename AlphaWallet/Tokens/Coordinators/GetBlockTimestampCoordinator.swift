// Copyright © 2020 Stormbird PTE. LTD.

import Foundation
import BigInt
import PromiseKit
import web3swift

class GetBlockTimestampCoordinator {
    //TODO persist?
    private static var blockTimestampCache: [RPCServer: [BigUInt: Date]] = .init()

    func getBlockTimestamp(_ blockNumber: BigUInt, onServer server: RPCServer) -> Promise<Date> {
        var cacheForServer = Self.blockTimestampCache[server] ?? .init()
        if let date = cacheForServer[blockNumber] {
            return .value(date)
        }

        guard let webProvider = Web3HttpProvider(server.rpcURL, network: server.web3Network) else {
            return Promise(error: Web3Error(description: "Error creating web provider for: \(server.rpcURL) + \(server.web3Network)"))
        }
        let web3 = web3swift.web3(provider: webProvider)
        return web3.eth.getBlockByNumberPromise(blockNumber).map {
            let result = $0.timestamp
            cacheForServer[blockNumber] = result
            Self.blockTimestampCache[server] = cacheForServer
            return result
        }
    }
}
