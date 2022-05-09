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
        // get all binded AddressIDs
        pub fun getBindedAddressIDs(): [FloidUtils.AddressID]
        // check if address id is binded 
        pub fun isBinded(addrID: FloidUtils.AddressID): Bool
        // get the last Message
        pub fun getLastBindingMessage(): FloidUtils.ExpirableMessage?
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

        // get all binded AddressIDs
        pub fun getBindedAddressIDs(): [FloidUtils.AddressID] {
            let ret: [FloidUtils.AddressID] = []
            for chainId in self.bindingMap.keys {
                let dic = &self.bindingMap[chainId]! as &{String: FloidUtils.AddressID}
                for id in dic.keys {
                    ret.append(dic[id]!)
                }
            }
            return ret
        }

        // check if address id is binded 
        pub fun isBinded(addrID: FloidUtils.AddressID): Bool {
            if let addresses = self.bindingMap[addrID.getChainID()] {
                return addresses.containsKey(addrID.toString())
            }
            return false
        }

        // get the last Message
        pub fun getLastBindingMessage(): FloidUtils.ExpirableMessage? {
            return self.pendingMessages.getLastMessage()
        }

        // --- Setters - Resource Interfaces ---

        // generate a new binding message to verify
        pub fun generateBindingMessage(): String {
            let fifteenMin: UFix64 = 1000.0 * 60.0 * 15.0
            let prefix = "Binding <0x".concat(self.getOwner().toString()).concat("> - Code: ")
            let keyString = self.pendingMessages.generateNewMessage(expireIn: fifteenMin, prefix: prefix)

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

            // binding to Protocol
            self.updateProtocolReverseIndex(addrID: addrID)

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

        // update protocol reverse index
        access(self) fun updateProtocolReverseIndex(addrID: FloidUtils.AddressID) {
            // global protocol
            let protocol = FloidProtocol.borrowProtocolPublic()

            let addrIDKey = addrID.toString()
            let currentBindings = protocol.getReverseBindings(FloidProtocol.ReverseIndexType.ThirdPartyChain, key: addrIDKey)
            // remove the exists one
            if currentBindings.length > 0 {
                for address in currentBindings {
                    protocol.updateReverseIndex(
                        FloidProtocol.ReverseIndexType.ThirdPartyChain,
                        key: addrIDKey,
                        address: address,
                        remove: true, 
                        ensureRegistered: false
                    )
                }
            }

            // binding current address
            protocol.updateReverseIndex(
                FloidProtocol.ReverseIndexType.ThirdPartyChain,
                key: addrIDKey,
                address: self.getOwner(),
                remove: false, 
                ensureRegistered: true
            )
        }
    }

    // create a resource of the store
    pub fun createStore(): @Store {
      return <- create Store()
    }
}
