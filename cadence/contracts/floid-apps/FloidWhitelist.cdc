/**

# The contract of Floid Whitelist App

*/

import FloidProtocol from "../FloidProtocol.cdc"

pub contract FloidWhitelist {

    /**    ___  ____ ___ _  _ ____
       *   |__] |__|  |  |__| [__
        *  |    |  |  |  |  | ___]
         *************************/

    // TODO

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/

    pub event ContractInitialized()

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    // pub resource Airdrop


    init() {
        // self.FloidAirdropPoolStoragePath = /storage/FloidAirdropPoolPath
        // self.FloidAirdropPoolPublicPath = /public/FloidAirdropPoolPath

        emit ContractInitialized()
    }
}