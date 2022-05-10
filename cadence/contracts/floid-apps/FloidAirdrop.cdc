/**

# The contract of Floid Airdrop App

*/
import NonFungibleToken from "../core/NonFungibleToken.cdc"
import FungibleToken from "../core/FungibleToken.cdc"
import FloidProtocol from "../FloidProtocol.cdc"
import Floid from "../Floid.cdc"

pub contract FloidAirdrop {

    /**    ___  ____ ___ _  _ ____
       *   |__] |__|  |  |__| [__
        *  |    |  |  |  |  | ___]
         *************************/

    pub let FloidAirdropDashboardStoragePath: StoragePath
    pub let FloidAirdropDashboardPublicPath: PublicPath

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/

    pub event ContractInitialized()
    pub event FloidAirdropPoolCreated(owner: Address, id: UInt64)
    pub event FloidAirdropNonFungibleTokenClaimed(nftType: Type, nftID: UInt64, recipient: Address)
    pub event FloidAirdropFungibleTokenClaimed(nftType: Type, amount: UFix64, recipient: Address)

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    pub resource interface AirdropPoolPublic {

    }

    // Resource of the airdrop pool
    pub resource AirdropPool: AirdropPoolPublic {
        init() {

        }

        // --- Getters - Public Interfaces ---

        // --- Getters - Private Interfaces ---

        // --- Setters - Contract Only ---

        // --- Self Only ---
    }

    // A public interface of AirdropDashboard
    pub resource interface AirdropDashboardPublic {
        // borrow the reference of airdrop pool
        pub fun borrowAirdropPool(id: UInt64): &AirdropPool{AirdropPoolPublic}
    }

    // A private interface of AirdropDashboard
    pub resource interface AirdropDashboardPrivate {

    }

    // Resource of the AirdropDashboard
    pub resource AirdropDashboard: AirdropDashboardPublic, AirdropDashboardPrivate {
        access(self) let airdrops: @{UInt64: AirdropPool}

        init() {
            self.airdrops <- {}
        }

        destroy() {
            destroy self.airdrops
        }

        // --- Getters - Public Interfaces ---

        pub fun borrowAirdropPool(id: UInt64): &AirdropPool{AirdropPoolPublic} {
            pre {
                self.airdrops[id] != nil: "Airdrop pool does not exist in the dashboard!"
            }
            return (&self.airdrops[id] as &AirdropPool{AirdropPoolPublic}?)!
        }

        // --- Getters - Private Interfaces ---



        // --- Setters - Contract Only ---

        // --- Self Only ---
    }

    // ---- contract methods ----

    // create the AirdropDashboard resource
    pub fun createAirdropDashboard(): @AirdropDashboard {
        return <- create AirdropDashboard()
    }

    init() {
        self.FloidAirdropDashboardStoragePath = /storage/FloidAirdropDashboardPath
        self.FloidAirdropDashboardPublicPath = /public/FloidAirdropDashboardPath

        emit ContractInitialized()
    }
}