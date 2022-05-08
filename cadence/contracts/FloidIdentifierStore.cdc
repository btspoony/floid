/**

# The contract of Floid Interfaces

*/

pub contract interface FloidIdentifierStore {

    // A public interface to Floid identifier
    pub resource interface StorePublic {
        // get owner address
        pub fun getOwner(): Address {
            pre {
                self.owner != nil: "When invoke this method, owner should not be nil."
            }
        }
    }

    // Requirement for the the concrete resource type
    // to be declared in the implementing contract
    //
    pub resource Store: StorePublic {
        pub fun getOwner(): Address
    }
    
    // createStore creates an empty Store
    pub fun createStore(): @Store
}
