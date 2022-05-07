/**

# The contract of Floid Protocol

> Author: Bohao Tang<tech@btang.cn>

## `FloidProtocol` resource

todo

## `FloidIdentifier` resource

todo

*/
import Crypto
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
    pub event FloidIdentifierRegistered(owner: Address, sequence: UInt256)
    pub event FloidIdentifierStoreTransferKeyGenerated(owner: Address, storeType: UInt8, key: String)
    pub event FloidIdentifierStoreTransfered(sender: Address, storeType: UInt8, recipient: Address)

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
        pub case AddressBinding
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

    // A public interface to address binding store
    pub resource interface AddressBindingStorePublic {

    }

    // third party address binding store
    pub resource AddressBindingStore: FloidIdentifierStore, AddressBindingStorePublic {

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

    // A public interface to kv store
    pub resource interface KeyValueStorePublic {
        pub fun getStringValue(_ key: String): String?
        pub fun getBooleanValue(_ key: String): Bool?
        pub fun getIntegerValue(_ key: String): Integer?
        pub fun getFixedPointValue(_ key: String): FixedPoint?
    }

    // key value store
    pub resource KeyValueStore: FloidIdentifierStore, KeyValueStorePublic {
        access(self) let kvStore: {String: AnyStruct}

        init() {
            self.kvStore = {}
        }

        // --- Getters - Public Interfaces ---

        pub fun getOwner(): Address {
            return self.owner!.address
        }

        pub fun getStringValue(_ key: String): String? {
            let ret = self.kvStore[key]
            if ret == nil || !ret.isInstance(Type<String>()) {
                return  nil
            } else {
                return ret as! String
            }
        }

        pub fun getBooleanValue(_ key: String): Bool? {
            let ret = self.kvStore[key]
            if ret == nil || !ret.isInstance(Type<Bool>()) {
                return  nil
            } else {
                return ret as! Bool
            }
        }

        pub fun getIntegerValue(_ key: String): Integer? {
            let ret = self.kvStore[key]
            if ret == nil || !ret.isInstance(Type<Integer>()) {
                return  nil
            } else {
                return ret as! Integer
            }
        }

        pub fun getFixedPointValue(_ key: String): FixedPoint? {
            let ret = self.kvStore[key]
            if ret == nil || !ret.isInstance(Type<FixedPoint>()) {
                return  nil
            } else {
                return ret as! FixedPoint
            }
        }

        // --- Setters - Private Interfaces ---

        // set any value to the kv store
        pub fun setValue(_ key: String, value: AnyStruct) {
            self.kvStore[key] = value
        }

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
        // get sequence of the identifier
        pub fun getSequence(): UInt256
        // borrow keyvalue store
        pub fun borrowKVStore(): &KeyValueStore{KeyValueStorePublic}?
        // borrow address binding store
        pub fun borrowAddressBindingStore(): &AddressBindingStore{AddressBindingStorePublic}?

        // transfer store by key
        access(contract) fun transferStoreByKey(type: GenericStoreType, transferKey: String, sigTag: String, sigData: Crypto.KeyListSignature): @{FloidIdentifierStore}
    }
    
    // A private interface to Floid identifier
    pub resource interface FloidIdentifierPrivate {
        // inherit data from another Floid identifier 
        pub fun inheritStore(from: Address, type: GenericStoreType, transferKey: String, sigTag: String, sigData: Crypto.KeyListSignature)
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
                if let store = self.borrowKVStoreFull() {
                    let name = store.getStringValue("name")
                    let desc = store.getStringValue("desc")
                    let image = store.getStringValue("image")
                    if name != nil && image != nil {
                        var file: AnyStruct{MetadataViews.File}? = nil
                        if image!.slice(from: 0, upTo: 4) == "ipfs" {
                            file = MetadataViews.IPFSFile(cid: image!, path: "")
                        } else {
                            file = MetadataViews.HTTPFile(url: image!)
                        }
                        return MetadataViews.Display(
                            name: name!,
                            description: desc ?? "",
                            thumbnail: file!
                        )
                    }
                    return nil
                }
                return nil
            }
            return nil
        }

        pub fun getSequence(): UInt256 {
            return self.sequence
        }
        
        pub fun borrowKVStore(): &KeyValueStore{KeyValueStorePublic}? {
            return self.borrowKVStoreFull() as &KeyValueStore{KeyValueStorePublic}?
        }
        
        pub fun borrowAddressBindingStore(): &AddressBindingStore{AddressBindingStorePublic}? {
            return self.borrowAddressBindingStoreFull() as &AddressBindingStore{AddressBindingStorePublic}?
        }

        // --- Setters - Private Interfaces ---

        // inherit data from another Floid identifier 
        pub fun inheritStore(from: Address, type: GenericStoreType, transferKey: String, sigTag: String, sigData: Crypto.KeyListSignature) {
            pre {
                self.genericData[type] == nil: "Only 'nil' resource can be inherited"
            }
            // first ensure registered
            self.ensureRegistered()

            let sender = getAccount(from)
                .getCapability(Floid.FloidIdentifierPublicPath)
                .borrow<&FloidIdentifier{FloidIdentifierPublic}>()
                ?? panic("Failed to borrow identifier of sender address")

            let store <- sender.transferStoreByKey(type: type, transferKey: transferKey, sigTag: sigTag, sigData: sigData)
            self.genericData[type] <-! store

            emit FloidIdentifierStoreTransfered(
                sender: from,
                storeType: type.rawValue,
                recipient: self.owner!.address
            )
        }

        // generate a transfer key
        pub fun generateTransferKey(type: GenericStoreType): String {
            pre {
                self.genericData[type] != nil: "The store resource doesn't exist"
            }
            post {
                self.transferKeys[type]!.length <= 5: "Too many transfer keys"
            }
            // first ensure registered
            self.ensureRegistered()

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
                // no more than 5 keys
                if arr.length > 5 {
                    arr.removeLast()
                }
            } else {
                self.transferKeys[type] = [key]
            }

            emit FloidIdentifierStoreTransferKeyGenerated(
                owner: self.owner!.address,
                storeType: type.rawValue,
                key: keyString
            )
            return keyString
        }

        // --- Setters - Resource Only ---

        // clear a store
        pub fun clearStore(type: GenericStoreType) {
            let store <- self.genericData.remove(key: type) ?? panic("Missing data store")
            destroy store
        }

        // --- Setters - Contract Only ---

        // transfer data to another Floid identifier 
        access(contract) fun transferStoreByKey(type: GenericStoreType, transferKey: String, sigTag: String, sigData: Crypto.KeyListSignature): @{FloidIdentifierStore} {
            pre {
                self.genericData[type] != nil: "The store resource doesn't exist"
            }
            assert(self.verifyTransferKey(type: type, transferKey: transferKey), message: "Invalid transferKey: ".concat(transferKey))

            // verify signature
            let keyToVerify = self.owner!.keys.get(keyIndex: sigData.keyIndex) ?? panic("Failed to get account public key")
            let isValid = keyToVerify.publicKey.verify(
                signature: sigData.signature,
                signedData: transferKey.decodeHex(), // transfer key is the message
                domainSeparationTag: sigTag,
                hashAlgorithm: keyToVerify.hashAlgorithm
            )
            assert(isValid, message: "Signature of transfer key is invalid.")

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

        // verify transferKey
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

        // ensure the identifier is registered to protocol
        access(self) fun ensureRegistered() {
            let owner = self.owner ?? panic("Missing owner, identifier is not in user storage.")

            let protocol = Floid.borrowProtocolPublic()
            if !protocol.isRegistered(user: owner.address) {
                protocol.registerIdentifier(
                    user: owner.getCapability<&FloidIdentifier{FloidIdentifierPublic}>(Floid.FloidIdentifierPublicPath)
                )
            }
        }

        access(self) fun borrowKVStoreFull(): &KeyValueStore? {
            let store = &self.genericData[GenericStoreType.KVStore] as auth &{FloidIdentifierStore}?
            if store.isInstance(Type<@KeyValueStore>()) {
                return store as! &KeyValueStore
            }
            return nil
        }

        access(self) fun borrowAddressBindingStoreFull(): &AddressBindingStore? {
            let store = &self.genericData[GenericStoreType.AddressBinding] as auth &{FloidIdentifierStore}?
            if store.isInstance(Type<@AddressBindingStore>()) {
                return store as! &AddressBindingStore
            }
            return nil
        }
    }

    // A public interface to Floid Protocol
    pub resource interface FloidProtocolPublic {
        // borrow users' identifier
        pub fun borrowIdentifier(sequence: UInt256): &FloidIdentifier{FloidIdentifierPublic}?
        // check if registered to Protocol
        pub fun isRegistered(user: Address): Bool

        // register users' identifier
        access(contract) fun registerIdentifier(user: Capability<&FloidIdentifier{FloidIdentifierPublic}>)
    }

    // Resource of the Floid Protocol
    pub resource FloidProtocol: FloidProtocolPublic {
        // all registered identifiers
        access(self) let registeredAddresses: [Address]
        // all capabilities
        access(self) let registeredCapabilities: {UInt256: Capability<&FloidIdentifier{FloidIdentifierPublic}>}

        init() {
            self.registeredAddresses = []
            self.registeredCapabilities = {}
        }

        // --- Getters - Public Interfaces ---

        pub fun isRegistered(user: Address): Bool {
            return self.registeredAddresses.contains(user)
        }

        pub fun borrowIdentifier(sequence: UInt256): &FloidIdentifier{FloidIdentifierPublic}? {
            if let cap = self.registeredCapabilities[sequence] {
                return cap.borrow()
            }
            return nil
        }

        // --- Setters - Private Interfaces ---

        // --- Setters - Contract Only ---

        access(contract) fun registerIdentifier(user: Capability<&FloidIdentifier{FloidIdentifierPublic}>) {
            pre {
                !self.registeredAddresses.contains(user.address): "Address already registered."
            }
            let ref = user.borrow() ?? panic("Cannot borrow identifier public reference.")
            let seq = ref.getSequence()

            self.registeredAddresses.append(user.address)
            self.registeredCapabilities.insert(key: seq, user)

            emit FloidIdentifierRegistered(
                owner: user.address,
                sequence: seq
            )
        }

        // --- Self Only ---
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
    pub fun createIdentifier(): @FloidIdentifier {
        return <- create FloidIdentifier()
    }

    // borrow the public identifier by address
    pub fun borrowIdentifier(user: Address): &FloidIdentifier{FloidIdentifierPublic}? {
        return getAccount(user)
            .getCapability(self.FloidIdentifierPublicPath)
            .borrow<&FloidIdentifier{FloidIdentifierPublic}>()
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