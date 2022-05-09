/**

# The contract of Floid EmeraldID store

*/
import FloidInterface from "../FloidInterface.cdc"
import EmeraldIdentity from "../deps/EmeraldIdentity.cdc"

pub contract SocialIDStore {

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    // A public interface to kv store
    pub resource interface PublicInterface {
      // get discord id of current identifier
      pub fun getDiscordID(): String?
    }

    // The resource of key value store
    pub resource Store: FloidInterface.StorePublic, PublicInterface {
        access(self) let extraBindings: {String: String}

        init() {
            self.extraBindings = {}
        }

        // --- Getters - Public Interfaces ---

        pub fun getOwner(): Address {
            return self.owner!.address
        }

        pub fun getDiscordID(): String? {
            return EmeraldIdentity.getDiscordFromAccount(account: self.getOwner())
        }
    }
}
 