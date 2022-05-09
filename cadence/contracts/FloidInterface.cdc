/**

# The contract of Floid Interfaces

*/

pub contract interface FloidInterface {

    pub event ContractInitialized()

    // A public interface to Floid Store
    pub resource interface StorePublic {
        // get owner address
        pub fun getOwner(): Address {
            pre {
                self.owner != nil: "When invoke this method, owner should not be nil."
            }
        }
    }

    // A public interface to Floid identifier
    pub resource interface IdentifierPublic {
        // borrow keyvalue store
        pub fun borrowStore(key: UInt8): &{StorePublic}
    }
    
    // Resource of the Floid identifier
    pub resource Identifier: IdentifierPublic {
        // Dictionary to hold the Stores in the Identifier
        pub let genericStores: @{UInt8: {StorePublic}}

        pub fun borrowStore(key: UInt8): &{StorePublic} {
            pre {
                self.genericStores[key] != nil: "Store does not exist in the identifier!"
            }
        }
    }

    // create a resource instance of FloidIdentifier
    pub fun createIdentifier(acct: Address): @Identifier
}
