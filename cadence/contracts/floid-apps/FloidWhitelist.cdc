/**

# The contract of Floid Whitelist App

*/

import FloidProtocol from "../FloidProtocol.cdc"

pub contract FloidWhitelist {

    /**    ___  ____ ___ _  _ ____
       *   |__] |__|  |  |__| [__
        *  |    |  |  |  |  | ___]
         *************************/

    pub let FloidWhitelistsStoragePath: StoragePath
    pub let FloidWhitelistsPublicPath: PublicPath

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/

    pub event ContractInitialized()
    pub event FloidWhitelistPoolCreated(owner: Address, id: UInt64)

    /**    ____ ___ ____ ___ ____
       *   [__   |  |__|  |  |___
        *  ___]  |  |  |  |  |___
         ************************/

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    // Resource of the whitelist pool
    pub resource WhitelistPool {
        init() {

        }

        // --- Getters - Public Interfaces ---

        // --- Getters - Private Interfaces ---

        // --- Setters - Contract Only ---

        // --- Self Only ---
    }

    // Resource of the whitelists
    pub resource Whitelists {
        init() {

        }

        // --- Getters - Public Interfaces ---

        // --- Getters - Private Interfaces ---

        // --- Setters - Contract Only ---

        // --- Self Only ---
    }

    // ---- contract methods ----

    // create the whitelists resource
    pub fun createWhitelists(): @Whitelists {
        return <- create Whitelists()
    }

    init() {
        self.FloidWhitelistsStoragePath = /storage/FloidWhitelistsPath
        self.FloidWhitelistsPublicPath = /public/FloidWhitelistsPath

        emit ContractInitialized()
    }
}