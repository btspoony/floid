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
    pub event FloidIdentifierStoreInitialized(owner: Address, storeType: UInt8)
    pub event FloidIdentifierStoreTransferKeyGenerated(owner: Address, storeType: UInt8, key: String)
    pub event FloidIdentifierStoreTransfered(sender: Address, storeType: UInt8, recipient: Address)

    pub event FloidProtocolIdentifierRegistered(owner: Address, sequence: UInt256)
    pub event FloidProtocolReverseIndexUpdated(category: UInt8, key: String, address: Address, remove: Bool)

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

    // enum for supported chain type
    pub enum SupportedChainType: UInt8 {
        pub case EVM_COMPATIBLE
    }

    // Struct of Third party Address ID
    pub struct AddressID {
        pub let chain: SupportedChainType
        pub let address: String
        pub let referID: String?

        init(_ chain: SupportedChainType, address: String, referID: String?) {
            self.chain = chain
            self.address = address
            self.referID = referID
        }

        // get the identify string of chain id
        pub fun getChainID(): String {
            var chainID: String = "chainstd"
            switch self.chain {
            case SupportedChainType.EVM_COMPATIBLE:
                chainID = "eip155"
                break
            }
            return chainID.concat(":").concat(self.referID ?? "<x>")
        }

        // get the identify string of the address
        pub fun toString(): String {
            return self.getChainID().concat(":").concat(self.address)
        }
    }

    // parse Address id from string
    access(contract) fun parseAddressID(str: String): AddressID? {
        let parseIdx: [Int; 2] = [-1,-1]
        var i = 0
        var cnt = 0
        while i < str.length {
            if str[i] == ":" {
                if cnt >= 2 {
                    return nil
                }
                parseIdx[cnt] = i
                cnt = cnt + 1
            }
            i = i + 1
        }
        if parseIdx[0] < 0 || parseIdx[1] < 0 {
            return nil
        }

        let chainID = str.slice(from: 0, upTo: parseIdx[0])
        var chain: SupportedChainType? = nil
        switch chainID {
        case "eip155":
            chain = SupportedChainType.EVM_COMPATIBLE
            break
        }
        if chain == nil {
            return nil
        }
        return AddressID(chain!, address: str.slice(from: parseIdx[1], upTo: str.length), referID: str.slice(from: parseIdx[0], upTo: parseIdx[1]))
    }

    // --- expirable key and crypto verify ---

    pub struct ExpirableMessage {
        pub let msg: String
        pub let expireAt: UFix64

        init(_ msg: String, expire: UFix64) {
            self.msg = msg
            self.expireAt = expire
        }
    }

    // The struct of verifiable messages
    pub struct VerifiableMessages {
        access(self) let messages: [ExpirableMessage]
        access(self) let maxLengh: Int

        init(_ maxLengh: Int?) {
            self.messages = []
            self.maxLengh = maxLengh ?? 5
        }

        // check if the message is valid
        pub fun isMessageValid(message: String): Bool {
            let now = getCurrentBlock().timestamp
            var isValid = false

            for one in self.messages {
                if message == one.msg && now <= one.expireAt {
                    isValid = true
                    break
                }
            }
            return isValid
        }

        // generate a new message with expire time
        access(contract) fun generateNewMessage(expireIn: UFix64): String {
            post {
                self.messages.length <= self.maxLengh: "Too many messages"
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

            let keyString = String.encodeHex(idArr)
            let key = ExpirableMessage(keyString, expire: blockTime + expireIn)

            self.messages.insert(at: 0, key)
            // no more than 5 keys
            if self.messages.length > self.maxLengh {
                self.messages.removeLast()
            }

            return keyString
        }

        // verify a message and remove messages which expired
        // if not invalid, do nothing
        access(contract) fun verifyMessageSignatureAndCleanup(
            message: String,
            messagePrefix: String?,
            hashTag: String?,
            hashAlgorithm: HashAlgorithm,
            publicKey: [UInt8],
            signatureAlgorithm: SignatureAlgorithm,
            signature: [UInt8],
        ): Bool {
            // verify signature
            let messageToVerify = (messagePrefix ?? "").concat(message)
            let keyToVerify = PublicKey(publicKey: publicKey, signatureAlgorithm: signatureAlgorithm)
            let isValid = keyToVerify.verify(
                signature: signature,
                signedData: messageToVerify.decodeHex(),
                domainSeparationTag: hashTag ?? "",
                hashAlgorithm: hashAlgorithm
            )
            if !isValid {
                return false
            }

            // if valid, remove key data
            let now = getCurrentBlock().timestamp
            let expiredIds: [Int] = []
            for idx, one in self.messages {
                if message == one.msg || now > one.expireAt {
                    expiredIds.append(idx)
                }
            }
            for idx in expiredIds {
                self.messages.remove(at: idx)
            }
            return true
        }
    }

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
        // check if address id is binded 
        pub fun isBinded(addrID: AddressID): Bool
    }

    // third party address binding store
    pub resource AddressBindingStore: FloidIdentifierStore, AddressBindingStorePublic {
        // mapping of the binding AddressID {chainID: {addressID: AddressID}}
        access(self) let bindingMap: {String: {String: AddressID}}
        // all pending messages
        access(self) let pendingMessages: VerifiableMessages

        init() {
            self.bindingMap = {}
            self.pendingMessages = VerifiableMessages(25)
        }

        // --- Getters - Public Interfaces ---

        pub fun getOwner(): Address {
            return self.owner!.address
        }

        pub fun isBinded(addrID: AddressID): Bool {
            if let addresses = self.bindingMap[addrID.getChainID()] {
                return addresses.containsKey(addrID.toString())
            }
            return false
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
        // initialize a new store
        pub fun initializeStore(type: GenericStoreType)
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
        pub let genericStores: @{GenericStoreType: {FloidIdentifierStore}}
        // transfer keys
        access(self) let transferKeys: {GenericStoreType: VerifiableMessages}

        init() {
            self.sequence = Floid.totalIdentifiers
            self.genericStores <- {}
            self.transferKeys = {}

            emit FloidIdentifierCreated(sequence: self.sequence)

            Floid.totalIdentifiers = Floid.totalIdentifiers + 1
        }

        destroy() {
            destroy self.genericStores
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

        pub fun initializeStore(type: GenericStoreType) {
            pre {
                self.genericStores[type] == nil: "Only 'nil' resource can be initialized"
            }
            switch type {
            case GenericStoreType.KVStore:
                self.genericStores[GenericStoreType.KVStore] <-! create KeyValueStore()
                break
            case GenericStoreType.AddressBinding:
                self.genericStores[GenericStoreType.AddressBinding] <-! create AddressBindingStore()
                break
            }

            emit FloidIdentifierStoreInitialized(
                owner: self.owner!.address,
                storeType: type.rawValue
            )
        }

        // inherit data from another Floid identifier 
        pub fun inheritStore(from: Address, type: GenericStoreType, transferKey: String, sigTag: String, sigData: Crypto.KeyListSignature) {
            pre {
                self.genericStores[type] == nil: "Only 'nil' resource can be inherited"
            }
            // first ensure registered
            self.ensureRegistered()

            let sender = getAccount(from)
                .getCapability(Floid.FloidIdentifierPublicPath)
                .borrow<&FloidIdentifier{FloidIdentifierPublic}>()
                ?? panic("Failed to borrow identifier of sender address")

            let store <- sender.transferStoreByKey(type: type, transferKey: transferKey, sigTag: sigTag, sigData: sigData)
            self.genericStores[type] <-! store

            emit FloidIdentifierStoreTransfered(
                sender: from,
                storeType: type.rawValue,
                recipient: self.owner!.address
            )
        }

        // generate a transfer key
        pub fun generateTransferKey(type: GenericStoreType): String {pre {
                self.genericStores[type] != nil: "The store resource doesn't exist"
            }
            // first ensure registered
            self.ensureRegistered()
            
            let oneDay: UFix64 = 1000.0 * 60.0 * 60.0 * 24.0
            if self.transferKeys[type] == nil {
                self.transferKeys[type] = VerifiableMessages(5)
            }
            let keyString = self.transferKeys[type]!.generateNewMessage(expireIn: oneDay)

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
            let store <- self.genericStores.remove(key: type) ?? panic("Missing data store")
            destroy store
        }

        // --- Setters - Contract Only ---

        // transfer data to another Floid identifier 
        access(contract) fun transferStoreByKey(type: GenericStoreType, transferKey: String, sigTag: String, sigData: Crypto.KeyListSignature): @{FloidIdentifierStore} {
            pre {
                self.genericStores[type] != nil: "The store resource doesn't exist"
                self.transferKeys[type] != nil: "cannot find transfer key."
            }
            assert(self.transferKeys[type]!.isMessageValid(message: transferKey), message: "Invalid transferKey: ".concat(transferKey))

            // get key from account
            let keyToVerify = self.owner!.keys.get(keyIndex: sigData.keyIndex) ?? panic("Failed to get account public key")
            // verify signature
            let isValid = self.transferKeys[type]!.verifyMessageSignatureAndCleanup(
                message: transferKey,
                messagePrefix: nil,
                hashTag: sigTag,
                hashAlgorithm: keyToVerify.hashAlgorithm,
                publicKey: keyToVerify.publicKey.publicKey,
                signatureAlgorithm: keyToVerify.publicKey.signatureAlgorithm,
                signature: sigData.signature,
            )
            assert(isValid, message: "Signature of transfer key is invalid.")

            // move store
            let store <- self.genericStores.remove(key: type) ?? panic("Missing data store")

            // return store
            return <- store
        }

        // --- Self Only ---

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
            let store = &self.genericStores[GenericStoreType.KVStore] as auth &{FloidIdentifierStore}?
            if store.isInstance(Type<@KeyValueStore>()) {
                return store as! &KeyValueStore
            }
            return nil
        }

        access(self) fun borrowAddressBindingStoreFull(): &AddressBindingStore? {
            let store = &self.genericStores[GenericStoreType.AddressBinding] as auth &{FloidIdentifierStore}?
            if store.isInstance(Type<@AddressBindingStore>()) {
                return store as! &AddressBindingStore
            }
            return nil
        }
    }

    // enumerations of reverse index
    pub enum ReverseIndexType: UInt8 {
        pub case ThirdPartyChain
        pub case KeyToAddresses
    }

    // A public interface to Floid Protocol
    pub resource interface FloidProtocolPublic {
        // check if registered to Protocol
        pub fun isRegistered(user: Address): Bool
        // borrow users' identifier
        pub fun borrowIdentifier(sequence: UInt256): &FloidIdentifier{FloidIdentifierPublic}?
        // get reverse binding addresses
        pub fun getReverseBindings(_ category: ReverseIndexType, key: String): [Address]
        // sync KeyToAddress reverse index of any address
        pub fun syncPublicKeysReverseIndex(address: Address)

        // register users' identifier
        access(contract) fun registerIdentifier(user: Capability<&FloidIdentifier{FloidIdentifierPublic}>)
        // update reverse index
        access(contract) fun updateThirdPartyChainReverseIndex(addrID: AddressID, address: Address, remove: Bool)
    }

    // Resource of the Floid Protocol
    pub resource FloidProtocol: FloidProtocolPublic {
        // all registered identifiers
        access(self) let registeredAddresses: [Address]
        // all capabilities
        access(self) let registeredCapabilities: {UInt256: Capability<&FloidIdentifier{FloidIdentifierPublic}>}
        // reverse indexes
        access(self) let reverseMapping: {ReverseIndexType: {String: {Address: Bool}}}

        init() {
            self.registeredAddresses = []
            self.registeredCapabilities = {}
            self.reverseMapping = {}
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
                    remove: removeOrNot[i]
                )
                i = i + 1
            }
        }

        // --- Setters - Contract Only ---

        access(contract) fun registerIdentifier(user: Capability<&FloidIdentifier{FloidIdentifierPublic}>) {
            pre {
                !self.registeredAddresses.contains(user.address): "Address already registered."
            }
            let ref = user.borrow() ?? panic("Cannot borrow identifier public reference.")
            let seq = ref.getSequence()

            self.registeredAddresses.append(user.address)
            self.registeredCapabilities.insert(key: seq, user)

            emit FloidProtocolIdentifierRegistered(
                owner: user.address,
                sequence: seq
            )
        }

        access(contract) fun updateThirdPartyChainReverseIndex(addrID: AddressID, address: Address, remove: Bool) {
            pre {
                self.registeredAddresses.contains(address): "Address should be registered already."
            }
            let addrIDKey = addrID.toString()
            let currentBindings = self.getReverseBindings(ReverseIndexType.ThirdPartyChain, key: addrIDKey)
            if !remove && currentBindings.length > 0 {
                panic("Only one address can be binding to same AddressID")
            } else if remove && !currentBindings.contains(address) {
                return
            }

            // check binding in the identifier
            let user = Floid.borrowIdentifier(user: address) ?? panic("Failed to borrow floid identifier.")
            let bindingStore = user.borrowAddressBindingStore() ?? panic("Failed to borrow address binding store.")
            let isBinded = bindingStore.isBinded(addrID: addrID)
            assert((!remove && isBinded) || (remove && !isBinded), message: "The Address id binding state is invalid.")

            self.updateReverseIndex(ReverseIndexType.ThirdPartyChain, key: addrIDKey, address: address, remove: remove)
        }

        // --- Self Only ---

        access(self) fun updateReverseIndex(_ category: ReverseIndexType, key: String, address: Address, remove: Bool) {
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