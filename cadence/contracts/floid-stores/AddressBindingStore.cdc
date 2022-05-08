/**

# The contract of Floid Address binding store

*/

import FloidIdentifierStore from "../FloidIdentifierStore.cdc"
import FloidUtils from "../FloidUtils.cdc"

pub contract AddressBindingStore: FloidIdentifierStore {

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/

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

    // A public interface to address binding store
    pub resource interface PublicInterface {
        // check if address id is binded 
        pub fun isBinded(addrID: AddressID): Bool
    }

    // third party address binding store
    pub resource Store: FloidIdentifierStore.StorePublic, PublicInterface {
        // mapping of the binding AddressID {chainID: {addressID: AddressID}}
        access(self) let bindingMap: {String: {String: AddressID}}
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

        pub fun isBinded(addrID: AddressID): Bool {
            if let addresses = self.bindingMap[addrID.getChainID()] {
                return addresses.containsKey(addrID.toString())
            }
            return false
        }

        // --- Setters - Resource Interfaces ---

        // pub fun generateBindingMessage(): String {

        // }

        // --- Setters - Contract Only ---

        // --- Self Only ---

    }

    // create a resource of the store
    pub fun createStore(): @Store {
      return <- create Store()
    }
}

