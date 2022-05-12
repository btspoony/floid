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

    // Struct of whitelist
    pub struct WhitelistInfo {
        // constants
        pub let ftQuota: UFix64
        pub let nftQuota: UInt64
        // variable
        pub var claimable: Bool
        pub var ftClaimedAmount: UFix64
        pub var nftClaimedIds: [UInt64]

        init(ftQuota: UFix64, nftQuota: UInt64) {
            self.ftQuota = ftQuota
            self.nftQuota = nftQuota

            self.claimable = true
            self.ftClaimedAmount = 0.0
            self.nftClaimedIds = []
        }

        // update FT claimed amount
        access(contract) fun updateFTClaimed(amount: UFix64) {
            pre {
                self.ftQuota >= amount + self.ftClaimedAmount: "FT Quota is the maximium claimable amount."
            }
            post {
                self.ftClaimedAmount == before(self.ftClaimedAmount) + amount
            }
            self.ftClaimedAmount = self.ftClaimedAmount + amount
            self.updateClaimable()
        }

        // update NFT claimed amount
        access(contract) fun updateNFTClaimed(ids: [UInt64]) {
            pre {
                Int(self.nftQuota) >= ids.length + self.nftClaimedIds.length: "NFT Quota is the maximium claimable amount."
            }
            post {
                self.nftClaimedIds.length == before(self.nftClaimedIds.length) + ids.length
            }
            for id in ids {
                if !self.nftClaimedIds.contains(id) {
                    self.nftClaimedIds.append(id)
                }
            }
            self.updateClaimable()
        }

        access(self) fun updateClaimable() {
            if self.ftClaimedAmount == self.ftQuota && self.nftClaimedIds.length == Int(self.nftQuota) {
                self.claimable = false
            }
        }
    }
    
    pub resource interface AirdropPoolPublic {

    }

    // Resource of the airdrop pool
    pub resource AirdropPool: AirdropPoolPublic {
        access(self) let tokenType: Type
        access(self) let collection: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
        // access(self) let claims: {}
        access(self) let whitelist: {String: WhitelistInfo}

        init(
            type: Type,
            collection: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>,
            whitelist: {String: WhitelistInfo}
        ) {
            self.tokenType = type
            self.collection = collection
            self.whitelist = whitelist
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
        // borrow private reference
        pub fun borrowAirdropPoolRef(id: UInt64): &AirdropPool
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
            return self.borrowAirdropPoolRef(id: id) as &AirdropPool{AirdropPoolPublic}
        }

        // --- Getters - Private Interfaces ---

        pub fun borrowAirdropPoolRef(id: UInt64): &AirdropPool {
            pre {
                self.airdrops[id] != nil: "Airdrop pool does not exist in the dashboard!"
            }
            return (&self.airdrops[id] as &AirdropPool?)!
        }


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