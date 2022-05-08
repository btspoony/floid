/**

# The contract of Floid Protocol

> Author: Bohao Tang<tech@btang.cn>

## `FloidProtocol` resource

A public data sharing protocol

*/
import FloidUtils from "./FloidUtils.cdc"
import FloidInterface from "./FloidInterface.cdc"

pub contract FloidProtocol {

    /**    ___  ____ ___ _  _ ____
       *   |__] |__|  |  |__| [__
        *  |    |  |  |  |  | ___]
         *************************/

    pub let FloidProtocolStoragePath: StoragePath
    pub let FloidProtocolPublicPath: PublicPath

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/

    pub event ContractInitialized()

    pub event FloidProtocolIdentifierRegistered(owner: Address, sequence: UInt256)
    pub event FloidProtocolReverseIndexUpdated(category: UInt8, key: String, address: Address, remove: Bool)

    /**    ____ ___ ____ ___ ____
       *   [__   |  |__|  |  |___
        *  ___]  |  |  |  |  |___
         ************************/

    // the contract address where the FloidProtocol deployed
    access(contract) let contractAddress: Address

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    // enumerations of reverse index
    pub enum ReverseIndexType: UInt8 {
        pub case ThirdPartyChain
        pub case KeyToAddresses
    }

    // A public interface to Floid Protocol
    pub resource interface ProtocolPublic {
        // check if registered to Protocol
        pub fun isRegistered(user: Address): Bool
        // get reverse binding addresses
        pub fun getReverseBindings(_ category: ReverseIndexType, key: String): [Address]
        // sync KeyToAddress reverse index of any address
        pub fun syncPublicKeysReverseIndex(address: Address)

        // ---- contract methods ----
        // register users' identifier
        access(account) fun registerIdentifier(user: Capability<&{FloidInterface.IdentifierPublic}>)
        // update reverse index
        access(account) fun updateReverseIndex(
            _ category: ReverseIndexType,
            key: String,
            address: Address,
            remove: Bool,
            ensureRegistered: Bool,
            requiredStore: UInt8?,
        )
    }

    // Resource of the Floid Protocol
    pub resource Protocol: ProtocolPublic {
        // all capabilities
        access(self) let registered: {Address: Capability<&{FloidInterface.IdentifierPublic}>}
        // reverse indexes
        access(self) let reverseMapping: {ReverseIndexType: {String: {Address: Bool}}}

        init() {
            self.registered = {}
            self.reverseMapping = {}
        }

        // --- Getters - Public Interfaces ---

        pub fun isRegistered(user: Address): Bool {
            return self.registered.keys.contains(user)
        }

        pub fun getReverseBindings(_ category: ReverseIndexType, key: String): [Address] {
            let records = &self.reverseMapping[category] as &{String: {Address: Bool}}?
            if records == nil {
                return []
            }
            if records![key] == nil {
                return []
            }
            return records![key]!.keys
        }

        pub fun syncPublicKeysReverseIndex(address: Address) {
            let removeOrNot: [Bool] = []
            let availableKeys: [String] = []
            let accountKeys = getAccount(address).keys
            var i = 0
            while true {
                let currentKey = accountKeys.get(keyIndex: i)
                if currentKey == nil {
                    break
                }
                availableKeys.append(String.encodeHex(currentKey!.publicKey.publicKey))
                removeOrNot.append(currentKey!.isRevoked)
                i = i + 1
            }

            // update all keys
            i = 0
            while i < availableKeys.length {
                self.updateReverseIndex(
                    ReverseIndexType.KeyToAddresses,
                    key: availableKeys[i],
                    address: address,
                    remove: removeOrNot[i],
                    ensureRegistered: false,
                    requiredStore: nil
                )
                i = i + 1
            }
        }

        // --- Setters - Contract Only ---

        access(account) fun registerIdentifier(user: Capability<&{FloidInterface.IdentifierPublic}>) {
            pre {
                !self.isRegistered(user: user.address): "Address already registered."
            }
            let ref = user.borrow() ?? panic("Cannot borrow identifier public reference.")
            let seq = ref.getSequence()

            self.registered.insert(key: user.address, user)

            emit FloidProtocolIdentifierRegistered(
                owner: user.address,
                sequence: seq
            )
        }

        // update reverse index
        access(account) fun updateReverseIndex(
            _ category: ReverseIndexType,
            key: String,
            address: Address,
            remove: Bool,
            ensureRegistered: Bool,
            requiredStore: UInt8?,
        ) {
            // ensure registered
            if ensureRegistered {
                let cap = self.registered[address] ?? panic("Address is not registered")
                assert(cap.address == address, message: "address should be same")
                let user = cap.borrow() ?? panic("Failed to borrow identifier.")
                if let storeId = requiredStore {
                    user.borrowStore(key: storeId)
                }
            }

            // ensure record array
            if self.reverseMapping[category] == nil {
                self.reverseMapping[category] = {}
            }
            let records = (&self.reverseMapping[category] as &{String: {Address: Bool}}?)!
            if records[key] == nil {
                records.insert(key: key, {})
            }

            if remove && records[key]!.containsKey(address) {
                // to remove address
                records[key]!.remove(key: address)
            } else if !remove && !records[key]!.containsKey(address) {
                // to add address
                records[key]!.insert(key: address, true)
            } else {
                // no update
                return 
            }

            emit FloidProtocolReverseIndexUpdated(
                category: category.rawValue,
                key: key,
                address: address,
                remove: remove
            )
        }

        // --- Self Only ---

    }

    // ---- contract methods ----

    // borrow the public interface
    pub fun borrowProtocolPublic(): &Protocol{ProtocolPublic} {
        return getAccount(self.contractAddress)
            .getCapability(self.FloidProtocolPublicPath)
            .borrow<&Protocol{ProtocolPublic}>()
            ?? panic("Failed to borrow protocol public.")
    }

    init() {
        // set state
        self.contractAddress = self.account.address

        // paths
        self.FloidProtocolStoragePath = /storage/FloidProtocolPath
        self.FloidProtocolPublicPath = /public/FloidProtocolPath

        // create resource and link the public capability
        self.account.save(<- create Protocol(), to: self.FloidProtocolStoragePath)
        self.account.link<&Protocol{ProtocolPublic}>(
            self.FloidProtocolPublicPath,
            target: self.FloidProtocolStoragePath
        )

        emit ContractInitialized()
    }
}
 