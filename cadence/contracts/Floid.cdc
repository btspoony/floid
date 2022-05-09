/**

# The contract of Floid Protocol

> Author: Bohao Tang<tech@btang.cn>

## `FloidIdentifier` resource

a soul-bound resource with multiply data store

*/

import Crypto
import MetadataViews from "./core/MetadataViews.cdc"
import FloidUtils from "./FloidUtils.cdc"
import FloidInterface from "./FloidInterface.cdc"
import FloidProtocol from "./FloidProtocol.cdc"
import KeyValueStore from "./floid-stores/KeyValueStore.cdc"
import SocialIDStore from "./floid-stores/SocialIDStore.cdc"
import AddressBindingStore from "./floid-stores/AddressBindingStore.cdc"

pub contract Floid: FloidInterface {

    /**    ___  ____ ___ _  _ ____
       *   |__] |__|  |  |__| [__
        *  |    |  |  |  |  | ___]
         *************************/

    pub let FloidStoragePath: StoragePath
    pub let FloidPrivatePath: PrivatePath
    pub let FloidPublicPath: PublicPath

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/

    pub event ContractInitialized()

    pub event FloidCreated(sequence: UInt256)
    pub event FloidStoreInitialized(owner: Address, storeType: UInt8)
    pub event FloidStoreTransferKeyGenerated(owner: Address, storeType: UInt8, key: String)
    pub event FloidStoreTransfered(sender: Address, storeType: UInt8, recipient: Address)

    /**    ____ ___ ____ ___ ____
       *   [__   |  |__|  |  |___
        *  ___]  |  |  |  |  |___
         ************************/

    // total identifier created
    pub var totalIdentifiers: UInt256

    // floid generic data type
    pub enum GenericStoreType: UInt8 {
        pub case KVStore
        pub case AddressBinding
        pub case SocialID
    }

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    // A public interface to Floid identifier
    pub resource interface FloidPublic {
        // borrow keyvalue store
        pub fun borrowKVStore(): &KeyValueStore.Store{KeyValueStore.PublicInterface}?
        // borrow address binding store
        pub fun borrowAddressBindingStore(): &AddressBindingStore.Store{AddressBindingStore.PublicInterface}?
        // borrow emerald id store
        pub fun borrowSocialIDStore(): &SocialIDStore.Store{SocialIDStore.PublicInterface}?

        // transfer store by key
        access(contract) fun transferStoreByKey(type: GenericStoreType, transferKey: String, sigTag: String, sigData: Crypto.KeyListSignature): @{FloidInterface.StorePublic}
    }
    
    // A private interface to Floid identifier
    pub resource interface FloidPrivate {
        // initialize a new store
        pub fun initializeStore(store: @{FloidInterface.StorePublic})
        // inherit data from another Floid identifier 
        pub fun inheritStore(from: Address, type: GenericStoreType, transferKey: String, sigTag: String, sigData: Crypto.KeyListSignature)
        // generate a transfer key to start a data transfer to another Floid identifier 
        pub fun generateTransferKey(type: GenericStoreType): String
    }

    // Resource of the Floid identifier
    pub resource Identifier: FloidInterface.IdentifierPublic, FloidPublic, FloidPrivate, MetadataViews.Resolver {
        // initialize account, should be same as owner address
        access(self) let initAddress: Address
        // global sequence number
        pub let sequence: UInt256
        // a storage of generic data
        pub let genericStores: @{UInt8: {FloidInterface.StorePublic}}
        // transfer keys
        access(self) let transferKeys: {GenericStoreType: FloidUtils.VerifiableMessages}

        init(_ account: Address) {
            self.initAddress = account
            self.sequence = Floid.totalIdentifiers
            self.genericStores <- {}
            self.transferKeys = {}

            emit FloidCreated(sequence: self.sequence)

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
        
        // borrow keyvalue store
        pub fun borrowStore(key: UInt8): &{FloidInterface.StorePublic} {
            return (&self.genericStores[key] as &{FloidInterface.StorePublic}?)!
        }

        // borrow keyvalue store
        pub fun borrowKVStore(): &KeyValueStore.Store{KeyValueStore.PublicInterface}? {
            return self.borrowKVStoreFull() as &KeyValueStore.Store{KeyValueStore.PublicInterface}?
        }

        // borrow address binding store
        pub fun borrowAddressBindingStore(): &AddressBindingStore.Store{AddressBindingStore.PublicInterface}? {
            return self.borrowAddressBindingStoreFull() as &AddressBindingStore.Store{AddressBindingStore.PublicInterface}?
        }
        
        // borrow emerald id store
        pub fun borrowSocialIDStore(): &SocialIDStore.Store{SocialIDStore.PublicInterface}? {
            let store = &self.genericStores[GenericStoreType.SocialID.rawValue] as auth &{FloidInterface.StorePublic}?
            if store != nil && store.isInstance(Type<@SocialIDStore.Store>()) {
                return store as! &SocialIDStore.Store{SocialIDStore.PublicInterface}
            }
            return nil
        }

        // --- Setters - Private Interfaces ---

        pub fun initializeStore(store: @{FloidInterface.StorePublic}) {
            var storeType: GenericStoreType? = nil 
            if store.isInstance(Type<@KeyValueStore.Store>()) {
                storeType = GenericStoreType.KVStore
            } else if store.isInstance(Type<@AddressBindingStore.Store>()) {
                storeType = GenericStoreType.AddressBinding
            } else if store.isInstance(Type<@SocialIDStore.Store>()) {
                storeType = GenericStoreType.SocialID
            }

            assert(storeType != nil, message: "Invalid store type.")
            assert(self.genericStores[storeType!.rawValue] == nil, message: "Only 'nil' resource can be initialized")

            // first ensure registered
            self.ensureRegistered()

            self.genericStores[storeType!.rawValue] <-! store

            emit FloidStoreInitialized(
                owner: self.owner!.address,
                storeType: storeType!.rawValue
            )
        }

        // inherit data from another Floid identifier 
        pub fun inheritStore(from: Address, type: GenericStoreType, transferKey: String, sigTag: String, sigData: Crypto.KeyListSignature) {
            pre {
                self.genericStores[type.rawValue] == nil: "Only 'nil' resource can be inherited"
            }
            // first ensure registered
            self.ensureRegistered()

            let sender = getAccount(from)
                .getCapability(Floid.FloidPublicPath)
                .borrow<&Identifier{FloidPublic}>()
                ?? panic("Failed to borrow identifier of sender address")

            let store <- sender.transferStoreByKey(type: type, transferKey: transferKey, sigTag: sigTag, sigData: sigData)
            self.genericStores[type.rawValue] <-! store

            emit FloidStoreTransfered(
                sender: from,
                storeType: type.rawValue,
                recipient: self.owner!.address
            )
        }

        // generate a transfer key
        pub fun generateTransferKey(type: GenericStoreType): String {pre {
                self.genericStores[type.rawValue] != nil: "The store resource doesn't exist"
            }
            // first ensure registered
            self.ensureRegistered()
            
            let oneDay: UFix64 = 1000.0 * 60.0 * 60.0 * 24.0
            if self.transferKeys[type] == nil {
                self.transferKeys[type] = FloidUtils.VerifiableMessages(5)
            }
            let prefix = "Transfer store from <0x".concat(self.owner!.address.toString()).concat("> - Code: ")
            let keyString = self.transferKeys[type]!.generateNewMessage(expireIn: oneDay, prefix: prefix)

            emit FloidStoreTransferKeyGenerated(
                owner: self.owner!.address,
                storeType: type.rawValue,
                key: keyString
            )
            return keyString
        }

        // --- Setters - Resource Only ---

        // clear a store
        pub fun clearStore(type: GenericStoreType) {
            let store <- self.genericStores.remove(key: type.rawValue) ?? panic("Missing data store")
            destroy store
        }

        pub fun borrowKVStoreFull(): &KeyValueStore.Store? {
            let store = &self.genericStores[GenericStoreType.KVStore.rawValue] as auth &{FloidInterface.StorePublic}?
            if store != nil && store.isInstance(Type<@KeyValueStore.Store>()) {
                return store as! &KeyValueStore.Store
            }
            return nil
        }

        pub fun borrowAddressBindingStoreFull(): &AddressBindingStore.Store? {
            let store = &self.genericStores[GenericStoreType.AddressBinding.rawValue] as auth &{FloidInterface.StorePublic}?
            if store != nil && store.isInstance(Type<@AddressBindingStore.Store>()) {
                return store as! &AddressBindingStore.Store
            }
            return nil
        }

        // --- Setters - Contract Only ---

        // transfer data to another Floid identifier 
        access(contract) fun transferStoreByKey(type: GenericStoreType, transferKey: String, sigTag: String, sigData: Crypto.KeyListSignature): @{FloidInterface.StorePublic} {
            pre {
                self.genericStores[type.rawValue] != nil: "The store resource doesn't exist"
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
            let store <- self.genericStores.remove(key: type.rawValue) ?? panic("Missing data store")

            // return store
            return <- store
        }

        // --- Self Only ---

        // ensure the identifier is registered to protocol
        access(self) fun ensureRegistered() {
            let owner = self.owner ?? panic("Missing owner, identifier is not in user storage.")
            assert(owner.address == self.initAddress, message: "Owner should be never changed.")

            let protocol = FloidProtocol.borrowProtocolPublic()
            if !protocol.isRegistered(user: owner.address) {
                protocol.registerIdentifier(
                    user: owner.getCapability<&{FloidInterface.IdentifierPublic}>(Floid.FloidPublicPath)
                )
            }
        }
    }

    // ---- contract methods ----

    // create a resource instance of FloidIdentifier
    pub fun createIdentifier(acct: Address): @Identifier {
        return <- create Identifier(acct)
    }

    // borrow the public identifier by address
    pub fun borrowIdentifier(user: Address): &Identifier{FloidPublic}? {
        return getAccount(user)
            .getCapability(self.FloidPublicPath)
            .borrow<&Identifier{FloidPublic}>()
    }

    init() {
        // set state
        self.totalIdentifiers = 0

        // paths
        self.FloidStoragePath = /storage/FloidIdentifierPath
        self.FloidPrivatePath = /private/FloidIdentifierPath
        self.FloidPublicPath = /public/FloidIdentifierPath

        emit ContractInitialized()
    }
}
 