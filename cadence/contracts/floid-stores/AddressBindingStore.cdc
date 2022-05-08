/**

# The contract of Floid Address binding store

*/
import FloidInterface from "../FloidInterface.cdc"
import FloidUtils from "../FloidUtils.cdc"

pub contract AddressBindingStore {

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/

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
