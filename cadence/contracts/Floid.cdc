/**

# The contract of Floid Protocol

> Author: Bohao Tang<tech@btang.cn>

## `FloidProtocol` resource

todo

## `FloidIdentifier` resource

todo

*/

import MetadataViews from "./core/MetadataViews.cdc"

pub contract Floid {

    /**    ___  ____ ___ _  _ ____
       *   |__] |__|  |  |__| [__
        *  |    |  |  |  |  | ___]
         *************************/

    pub let FloidProtocolStoragePath: StoragePath
    pub let FloidProtocolPublicPath: PublicPath

    pub let FloidIdentifierStoragePath: StoragePath
    pub let FloidIdentifierPrivatePath: PrivatePath
    pub let FloidIdentifierPublicPath: PublicPath

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/

    pub event ContractInitialized()

    pub event FloidIdentifierCreated(sequence: UInt256)

    /**    ____ ___ ____ ___ ____
       *   [__   |  |__|  |  |___
        *  ___]  |  |  |  |  |___
         ************************/

    // total identifier created
    pub var totalIdentifiers: UInt256
    // the contract address where the FloidProtocol deployed
    access(contract) let contractAddress: Address

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    // floid generic data type
    pub enum GenericStoreType: UInt8 {
        pub case AddressesBinding
        pub case KVStore
    }
    
    // A public interface to Floid identifier
    pub resource interface FloidIdentifierStore {
        // get owner address
        pub fun getOwner(): Address {
            pre {
                self.owner != nil: "When invoke this method, owner should not be nil."
            }
        }
    }

    // third party address binding store
    pub resource AddressBindingStore: FloidIdentifierStore {

        init() {

        }

        // --- Getters - Public Interfaces ---

        pub fun getOwner(): Address {
            return self.owner!.address
        }

        // --- Setters - Private Interfaces ---

        // --- Setters - Contract Only ---

        // --- Self Only ---

    }

    // key value store
    pub resource KeyValueStore: FloidIdentifierStore {

        init() {

        }

        // --- Getters - Public Interfaces ---

        pub fun getOwner(): Address {
            return self.owner!.address
        }

        // --- Setters - Private Interfaces ---

        // --- Setters - Contract Only ---

        // --- Self Only ---

    }

    // helper struct
    pub struct TransferKey {
        pub let key: String
        pub let expireAt: UFix64

        init(_ key: String, expire: UFix64) {
            self.key = key
            self.expireAt = expire
        }
    }

    // A public interface to Floid identifier
    pub resource interface FloidIdentifierPublic {
        // // borrow the identifier store
        // pub fun borrowStore(type: GenericStoreType): &{FloidIdentifierStore}?

        // transfer store by key
        access(contract) fun transferStoreByKey(type: GenericStoreType, transferKey: String): @{FloidIdentifierStore}
    }
    
    // A private interface to Floid identifier
    pub resource interface FloidIdentifierPrivate {
        // inherit data from another Floid identifier 
        pub fun inheritStore(from: Address, type: GenericStoreType, transferKey: String)
        // generate a transfer key to start a data transfer to another Floid identifier 
        pub fun generateTransferKey(type: GenericStoreType): String
    }

    // Resource of the Floid identifier
    pub resource FloidIdentifier: FloidIdentifierPublic, FloidIdentifierPrivate, MetadataViews.Resolver {
        // global sequence number
        pub let sequence: UInt256
        // a storage of generic data
        pub let genericData: @{GenericStoreType: {FloidIdentifierStore}}
        // transfer keys
        access(self) let transferKeys: {GenericStoreType: [TransferKey]}

        init() {
            self.sequence = Floid.totalIdentifiers
            self.genericData <- {}
            self.transferKeys = {}

            emit FloidIdentifierCreated(sequence: self.sequence)

            Floid.totalIdentifiers = Floid.totalIdentifiers + 1
        }

        destroy() {
            destroy self.genericData
        }

        // --- Getters - Public Interfaces ---

        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    // TODO
                    return nil
            }
            return nil
        }

        // pub fun borrowStore(type: GenericStoreType): &{FloidIdentifierStore}? {
        //     return &self.genericData[type] as &{FloidIdentifierStore}?
        // }

        // --- Setters - Private Interfaces ---

        // inherit data from another Floid identifier 
        pub fun inheritStore(from: Address, type: GenericStoreType, transferKey: String) {
            pre {
                self.genericData[type] == nil: "Only 'nil' resource can be inherited"
            }
            let sender = getAccount(from)
                .getCapability(Floid.FloidIdentifierPublicPath)
                .borrow<&FloidIdentifier{FloidIdentifierPublic}>()
                ?? panic("Failed to borrow identifier of sender address")

            let store <- sender.transferStoreByKey(type: type, transferKey: transferKey)
            self.genericData[type] <-! store
        }

        // --- Setters - Resource Only ---

        // generate a transfer key
        pub fun generateTransferKey(type: GenericStoreType): String {
            pre {
                self.genericData[type] != nil: "The store resource doesn't exist"
            }
            post {
                self.transferKeys[type]!.length <= 5: "Too many transfer keys"
            }

            let block = getCurrentBlock()
            let blockId = block.id
            let blockTime = block.timestamp

            let idArr: [UInt8] = []
            var i = 0
            while i < 16 {
                idArr.append(blockId[Int(unsafeRandom() % 32)]!)
                i = i + 1
            }

            let oneDay: UFix64 = 1000.0 * 60.0 * 60.0 * 24.0
            let keyString = String.encodeHex(idArr)
            let key = TransferKey(keyString, expire: blockTime + oneDay)

            if let arr = self.transferKeys[type] {
                arr.insert(at: 0, key)
            } else {
                self.transferKeys[type] = [key]
            }
            return keyString
        }

        // clear a store
        pub fun clearStore(type: GenericStoreType) {
            let store <- self.genericData.remove(key: type) ?? panic("Missing data store")
            destroy store
        }

        // --- Setters - Contract Only ---

        // transfer data to another Floid identifier 
        access(contract) fun transferStoreByKey(type: GenericStoreType, transferKey: String): @{FloidIdentifierStore} {
            pre {
                self.genericData[type] != nil: "The store resource doesn't exist"
            }
            assert(self.verifyTransferKey(type: type, transferKey: transferKey), message: "Invalid transferKey: ".concat(transferKey))

            // move store
            let store <- self.genericData.remove(key: type) ?? panic("Missing data store")

            // remove key data
            let now = getCurrentBlock().timestamp
            let expiredIds: [Int] = []
            let keys = self.transferKeys[type]!
            for idx, one in keys {
                if transferKey == one.key || now > one.expireAt {
                    expiredIds.append(idx)
                }
            }
            for idx in expiredIds {
                self.transferKeys[type]!.remove(at: idx)
            }

            // return store
            return <- store
        }

        // --- Self Only ---

        access(self) fun verifyTransferKey(type: GenericStoreType, transferKey: String): Bool {
            pre {
                self.transferKeys[type] != nil: "cannot find transfer key."
            }
            let now = getCurrentBlock().timestamp
            var isValid = false

            let keys = self.transferKeys[type]!
            for one in keys {
                if transferKey == one.key && now <= one.expireAt {
                    isValid = true
                    break
                }
            }
            return isValid
        }
    }

    // A public interface to Floid Protocol
    pub resource interface FloidProtocolPublic {

    }

    // Resource of the Floid Protocol
    pub resource FloidProtocol: FloidProtocolPublic {

        init() {

        }
    }

    // ---- contract methods ----

    // borrow the public interface
    access(account) fun borrowProtocolPublic(): &FloidProtocol{FloidProtocolPublic} {
        return getAccount(Floid.contractAddress)
            .getCapability(Floid.FloidProtocolPublicPath)
            .borrow<&FloidProtocol{FloidProtocolPublic}>()
            ?? panic("Failed to borrow protocol public.")
    }

    // create a resource instance of FloidIdentifier
    pub fun createIdentifier(acct: Address): @FloidIdentifier {
        return <- create FloidIdentifier()
    }

    init() {
        // set state
        self.totalIdentifiers = 0
        self.contractAddress = self.account.address

        // paths
        self.FloidProtocolStoragePath = /storage/FloidProtocolPath
        self.FloidProtocolPublicPath = /public/FloidProtocolPath

        self.FloidIdentifierStoragePath = /storage/FloidIdentifierPath
        self.FloidIdentifierPrivatePath = /private/FloidIdentifierPath
        self.FloidIdentifierPublicPath = /public/FloidIdentifierPath

        // create resource and link the public capability
        self.account.save(<- create FloidProtocol(), to: self.FloidProtocolStoragePath)
        self.account.link<&FloidProtocol{FloidProtocolPublic}>(
            self.FloidProtocolPublicPath,
            target: self.FloidProtocolStoragePath
        )

        emit ContractInitialized()
    }
}