/**

# The contract of Floid Address binding store

*/
import Crypto
import FloidUtils from "../FloidUtils.cdc"
import FloidInterface from "../FloidInterface.cdc"
import FloidProtocol from "../FloidProtocol.cdc"

pub contract AddressBindingStore {

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/
    
    pub event FloidABStoreMessageGenerated(owner: Address, key: String)
    pub event FloidABStoreAddressIDBinded(owner: Address, addressID: String)

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    // A public interface to address binding store
    pub resource interface PublicInterface {
        // check if address id is binded 
        pub fun isBinded(addrID: FloidUtils.AddressID): Bool
    }

    // third party address binding store
    pub resource Store: FloidInterface.StorePublic, PublicInterface {
        // mapping of the binding AddressID {chainID: {addressID: AddressID}}
        access(self) let bindingMap: {String: {String: FloidUtils.AddressID}}
        // all pending messages
        access(self) let pendingMessages: FloidUtils.VerifiableMessages

        init() {
            self.bindingMap = {}
            self.pendingMessages = FloidUtils.VerifiableMessages(25)
        }

        // --- Getters - Public Interfaces ---

        pub fun getOwner(): Address {
            return self.owner!.address
        }

        pub fun isBinded(addrID: FloidUtils.AddressID): Bool {
            if let addresses = self.bindingMap[addrID.getChainID()] {
                return addresses.containsKey(addrID.toString())
            }
            return false
        }

        // --- Setters - Resource Interfaces ---

        // generate a new binding message to verify
        pub fun generateBindingMessage(): String {
            let fifteenMin: UFix64 = 1000.0 * 60.0 * 15.0
            let keyString = self.pendingMessages.generateNewMessage(expireIn: fifteenMin)

            emit FloidABStoreMessageGenerated(
                owner: self.getOwner(),
                key: keyString
            )
            return keyString
        }

        // verify the binding message
        pub fun verifyBindingMessage(
            _ addrID: FloidUtils.AddressID,
            message: String,
            hashAlgorithm: HashAlgorithm,
            publicKey: String,
            signatureAlgorithm: SignatureAlgorithm,
            signature: String,
        ) {
            let chainID = addrID.getChainID()
            let addressKey = addrID.toString()
            if self.bindingMap[chainID] == nil {
                self.bindingMap[chainID] = {}
            }
            assert(self.bindingMap[chainID]!.containsKey(addressKey), message: "Already binded")
            assert(self.verifyAddress(addrID, publicKey: publicKey), message: "The address is not same at the public key.")

            let prefix = self.generateMessagePreix(addrID.chain, message: message)
            let isValid = self.pendingMessages.verifyMessageSignatureAndCleanup(
                message: message,
                messagePrefix: prefix,
                hashTag: nil,
                hashAlgorithm: hashAlgorithm,
                publicKey: publicKey.decodeHex(),
                signatureAlgorithm: signatureAlgorithm,
                signature: signature.decodeHex()
            )
            assert(isValid, message: "Signature of binding message is invalid.")

            self.bindingMap[chainID]!.insert(key: addressKey, addrID)

            // TODO binding to Protocol

            emit FloidABStoreAddressIDBinded(
                owner: self.getOwner(),
                addressID: addressKey
            )
        }

        // --- Setters - Contract Only ---

        // --- Self Only ---

        // verify address by publicKey
        access(self) fun verifyAddress(
            _ addrID: FloidUtils.AddressID,
            publicKey: String,
        ): Bool {
            if addrID.chain == FloidUtils.SupportedChainType.EVM_COMPATIBLE {
                let calcAddr = self.generateEVMAddressByPublicKey(key: publicKey)
                return calcAddr == addrID.address
            }
            return true
        }

        access(self) fun generateMessagePreix(
            _ chain: FloidUtils.SupportedChainType,
            message: String
        ): String {
            if chain == FloidUtils.SupportedChainType.EVM_COMPATIBLE {
                let ethPrefix = "\u{19}Ethereum Signed Message:\n"
                return ethPrefix.concat(message.length.toString())
            }
            return ""
        }

        // generate evm address by the public key
        access(self) fun generateEVMAddressByPublicKey(key: String): String {
            var keyArr = key.decodeHex()
            if keyArr.length == 65 {
                keyArr = keyArr.slice(from: 1, upTo: 64)
            }
            assert(keyArr.length == 64, message: "PublicKey Length should be 65")
            let hash: [UInt8] = HashAlgorithm.KECCAK_256.hash(keyArr)
            return "0x".concat(String.encodeHex(hash.slice(from: hash.length - 20, upTo: hash.length - 1)))
        }
    }

    // access(account) fun updateThirdPartyChainReverseIndex(addrID: FloidUtils.AddressID, address: Address, remove: Bool) {
    //     pre {
    //         self.registeredAddresses.contains(address): "Address should be registered already."
    //     }
    //     let addrIDKey = addrID.toString()
    //     let currentBindings = self.getReverseBindings(ReverseIndexType.ThirdPartyChain, key: addrIDKey)
    //     if !remove && currentBindings.length > 0 {
    //         panic("Only one address can be binding to same AddressID")
    //     } else if remove && !currentBindings.contains(address) {
    //         return
    //     }

    //     // check binding in the identifier
    //     let user = Floid.borrowIdentifier(user: address) ?? panic("Failed to borrow floid identifier.")
    //     let bindingStore = user.borrowAddressBindingStore() ?? panic("Failed to borrow address binding store.")
    //     let isBinded = bindingStore.isBinded(addrID: addrID)
    //     assert((!remove && isBinded) || (remove && !isBinded), message: "The Address id binding state is invalid.")

    //     self.updateReverseIndex(ReverseIndexType.ThirdPartyChain, key: addrIDKey, address: address, remove: remove)
    // }

    // create a resource of the store
    pub fun createStore(): @Store {
      return <- create Store()
    }
}
