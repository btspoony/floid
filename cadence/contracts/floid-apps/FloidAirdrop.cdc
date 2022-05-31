/**

# The contract of Floid Airdrop App

*/
import NonFungibleToken from "../core/NonFungibleToken.cdc"
import FungibleToken from "../core/FungibleToken.cdc"
import FloidProtocol from "../FloidProtocol.cdc"
import FloidUtils from "../FloidUtils.cdc"
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
    pub event FloidAirdropPoolCreated(owner: Address, id: UInt64, isNFT: Bool)

    pub event FloidAirdropFungibleTokenClaimed(type: Type, amount: UFix64, recipient: Address)
    pub event FloidAirdropNonFungibleTokenClaimed(type: Type, nftID: UInt64, recipient: Address)

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    // Struct interface of whitelist
    pub struct interface IWhitelistInfo {
        // check if claimable
        pub fun isClaimable(): Bool
    }

    // Struct of ft whitelist info
    pub struct FungibleWhitelist: IWhitelistInfo {
        // constants
        pub let quota: UFix64
        // variable
        pub var claimedAmount: UFix64

        init(quota: UFix64) {
            self.quota = quota
            self.claimedAmount = 0.0
        }

        // check if claimable
        pub fun isClaimable(): Bool {
            return self.claimedAmount < self.quota
        }

        // update FT claimed amount
        access(contract) fun updateClaimed(amount: UFix64) {
            pre {
                self.quota >= amount + self.claimedAmount: "FT Quota is the maximium claimable amount."
            }
            post {
                self.claimedAmount == before(self.claimedAmount) + amount
            }
            self.claimedAmount = self.claimedAmount + amount
        }
    }

    // Struct of nft whitelist info
    pub struct NonFungibleWhitelist: IWhitelistInfo {
        // constants
        pub let quota: UInt64
        // variable
        pub var claimedIds: [UInt64]

        init(quota: UInt64) {
            self.quota = quota
            self.claimedIds = []
        }

        // check if claimable
        pub fun isClaimable(): Bool {
            return self.claimedIds.length < Int(self.quota)
        }

        // update NFT claimed amount
        access(contract) fun updateClaimed(ids: [UInt64]) {
            pre {
                Int(self.quota) >= ids.length + self.claimedIds.length: "NFT Quota is the maximium claimable amount."
            }
            post {
                self.claimedIds.length == before(self.claimedIds.length) + ids.length
            }
            for id in ids {
                if !self.claimedIds.contains(id) {
                    self.claimedIds.append(id)
                }
            }
        }
    }

    // A struct of airdrop pool display
    pub struct AirdropPoolDisplay {
        pub let name: String
        pub let description: String
        pub let image: String

        init(
            name: String,
            description: String,
            image: String,
        ) {
            self.name = name
            self.description = description
            self.image = image
        }
    }

    // An interface of all Airdrop pool
    pub resource interface AirdropPoolPublic {
        // return the airdrop display
        pub fun getDisplay(): AirdropPoolDisplay
        // check if the pool is claimable
        pub fun isPoolClaimable(): Bool
        // check is the address has been claimed
        pub fun hasClaimed(_ address: Address): Bool
        // check if the address is claimable
        pub fun isClaimable(_ address: Address): Bool
    }

    // An interface of FT Airdrop pool
    pub resource interface AirdropFungiblePoolPublic {
        // Claim the fungible token from pool
        pub fun claim(
            recipient: &FungibleToken.Vault
        )
    }

    pub resource AirdropFungibleTokenPool: AirdropPoolPublic, AirdropFungiblePoolPublic {
        access(self) let display: AirdropPoolDisplay

        access(self) let tokenProvider: Capability<&{FungibleToken.Provider, FungibleToken.Balance}>
        access(self) let whitelist: {String: FungibleWhitelist}
        access(self) let totalQuota: UFix64

        access(self) var totalClaimed: UFix64
        access(self) var claimed: {Address: UFix64}

        init(
            _ display: AirdropPoolDisplay,
            provider: Capability<&{FungibleToken.Provider, FungibleToken.Balance}>,
            whitelist: {String: FungibleWhitelist}
        ) {
            pre {
                provider.borrow() != nil: "Provider should be no 'nil'"
            }
            self.display = display

            self.tokenProvider = provider

            var totalQuota: UFix64 = 0.0
            self.whitelist = whitelist
            for key in whitelist.keys {
                let one = whitelist[key]!
                totalQuota = totalQuota + one.quota
            }
            self.totalQuota = totalQuota
            self.totalClaimed = 0.0
            self.claimed = {}
        }

        // --- Getters - Public Interfaces ---

        pub fun getDisplay(): AirdropPoolDisplay {
            return self.display
        }

        pub fun isPoolClaimable(): Bool {
            return self.totalClaimed < self.totalQuota
        }

        pub fun hasClaimed(_ address: Address): Bool {
            return self.claimed[address] != nil && self.claimed[address]! > 0.0
        }

        pub fun isClaimable(_ address: Address): Bool {
            var info = self.getClaimableInfo(address)
            if info == nil {
                return false
            }
            return info!.isClaimable()
        }

        // Claim the fungible token from pool
        pub fun claim(
            recipient: &FungibleToken.Vault
        ) {
            pre {
                self.isPoolClaimable(): "Currently pool is not claimable"
                recipient.owner != nil: "Recipient owner should exist"
            }
            let claimer = recipient.owner!.address
            let whitelistInfo = self.getClaimableInfo(claimer) ?? panic("Failed to get claimable whitelist info.")
            // token provider
            let tokenProvider = self.tokenProvider.borrow() ?? panic("Failed to borrow token provider.")
            assert(recipient.getType().identifier == tokenProvider.getType().identifier, message: "Token should be same type.")
            assert(whitelistInfo.quota <= tokenProvider.balance, message: "Not enougth token balance to claim.")

            // transfer token
            recipient.deposit(from: <- tokenProvider.withdraw(amount: whitelistInfo.quota))

            // update claimed
            whitelistInfo.updateClaimed(amount: whitelistInfo.quota)
            self.totalClaimed = self.totalClaimed + whitelistInfo.quota

            emit FloidAirdropFungibleTokenClaimed(
                type: recipient.getType(),
                amount: whitelistInfo.quota,
                recipient: claimer
            )
        }

        // --- Getters - Private Interfaces ---

        // --- Setters - Contract Only ---

        // --- Self Only ---

        access(self) fun getClaimableInfo(_ address: Address): &FungibleWhitelist? {
            let bindings = FloidAirdrop.getBindingAddressIDs(address)
            var info: &FungibleWhitelist? = nil
            for one in bindings {
                let bindingKey = one.toString()
                if self.whitelist.containsKey(bindingKey) {
                    let whitelist = &self.whitelist[bindingKey] as &FungibleWhitelist?
                    if whitelist!.isClaimable() {
                        info = whitelist
                        break
                    }
                }
            }
            return info
        }
    }

    // An interface of NFT Airdrop pool
    pub resource interface AirdropNonFungiblePoolPublic {
        pub fun claim(
            recipient: &NonFungibleToken.Collection
        )
    }

    // Resource of the airdrop pool
    pub resource AirdropNonFungibleTokenPool: AirdropPoolPublic, AirdropNonFungiblePoolPublic {
        access(self) let display: AirdropPoolDisplay

        access(self) let tokenType: Type
        access(self) let collection: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
        access(self) let whitelist: {String: NonFungibleWhitelist}
        access(self) let totalQuota: UInt64
        access(self) let including: [UInt64]
        access(self) let excluding: [UInt64]

        access(self) var totalClaimed: UInt64
        access(self) var claimed: {Address: [UInt64]}

        init(
            _ display: AirdropPoolDisplay,
            type: Type,
            collection: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>,
            whitelist: {String: NonFungibleWhitelist},
            totalQuota: UInt64,
            including: [UInt64],
            excluding: [UInt64],
        ) {
            self.display = display

            self.tokenType = type
            self.collection = collection
            self.whitelist = whitelist

            let collectionRef = collection.borrow() ?? panic("Failed to borrow collection reference.")
            let ids = collectionRef.getIDs()
            assert(Int(totalQuota) <= ids.length, message: "total quota should smaller then ids.")
            self.totalQuota = totalQuota
            self.including = including
            self.excluding = excluding

            self.totalClaimed = 0
            self.claimed = {}
        }

        // --- Getters - Public Interfaces ---

        pub fun getDisplay(): AirdropPoolDisplay {
            return self.display
        }

        pub fun isPoolClaimable(): Bool {
            return self.totalClaimed < self.totalQuota
        }

        pub fun hasClaimed(_ address: Address): Bool {
            return self.claimed[address] != nil && self.claimed[address]!.length > 0
        }

        pub fun isClaimable(_ address: Address): Bool {
            var info = self.getClaimableInfo(address)
            if info == nil {
                return false
            }
            return info!.isClaimable()
        }

        pub fun claim(
            recipient: &NonFungibleToken.Collection
        ) {
            pre {
                self.isPoolClaimable(): "Currently pool is not claimable"
                recipient.owner != nil: "Recipient owner should exist"
            }
            let claimer = recipient.owner!.address
            let whitelistInfo = self.getClaimableInfo(claimer) ?? panic("Failed to get claimable whitelist info.")
            // collection
            let collection = self.collection.borrow() ?? panic("Failed to borrow collection.")
            assert(recipient.getType().identifier == collection.getType().identifier, message: "Token should be same type.")

            let ids = collection.getIDs()
            assert(Int(whitelistInfo.quota) <= ids.length, message: "Not enougth nft to claim.")

            // transfer token
            let transfered: [UInt64] = []
            var i: UInt64 = 0
            while i < whitelistInfo.quota && ids.length > 0 {
                let idToWithdraw = ids.removeFirst()
                if self.including.length > 0 && !self.including.contains(idToWithdraw) {
                    continue
                } else if self.excluding.length > 0 && self.excluding.contains(idToWithdraw) {
                    continue
                }
                let nft <- collection.withdraw(withdrawID: idToWithdraw)
                assert(nft.isInstance(self.tokenType), message: "NFT type should be some")
                let nftID = nft.id
                transfered.append(nftID)

                recipient.deposit(token: <- nft)

                emit FloidAirdropNonFungibleTokenClaimed(
                    type: self.tokenType,
                    nftID: nftID,
                    recipient: claimer
                )
                i = i + 1
            }

            assert(transfered.length > 0, message: "No NFT transfered.")

            // update claimed
            whitelistInfo.updateClaimed(ids: transfered)
            self.totalClaimed = self.totalClaimed + whitelistInfo.quota
        }

        // --- Getters - Private Interfaces ---

        // --- Setters - Contract Only ---

        // --- Self Only ---

        access(self) fun getClaimableInfo(_ address: Address): &NonFungibleWhitelist? {
            let bindings = FloidAirdrop.getBindingAddressIDs(address)
            var info: &NonFungibleWhitelist? = nil
            for one in bindings {
                let bindingKey = one.toString()
                if self.whitelist.containsKey(bindingKey) {
                    let whitelist = &self.whitelist[bindingKey] as &NonFungibleWhitelist?
                    if whitelist!.isClaimable() {
                        info = whitelist
                        break
                    }
                }
            }
            return info
        }
    }

    // A public interface of AirdropDashboard
    pub resource interface AirdropDashboardPublic {
        // get all ids
        pub fun getIDs(isNFT: Bool): [UInt64]
        // borrow the reference of airdrop fungible pool
        pub fun borrowAirdropFungiblePool(id: UInt64): &{AirdropPoolPublic, AirdropFungiblePoolPublic}
        // borrow the reference of airdrop nonfungible pool
        pub fun borrowAirdropNonFungiblePool(id: UInt64): &{AirdropPoolPublic, AirdropNonFungiblePoolPublic}
    }

    // Resource of the AirdropDashboard
    pub resource AirdropDashboard: AirdropDashboardPublic {
        access(self) let airdropsNFT: @{UInt64: AirdropNonFungibleTokenPool}
        access(self) let airdropsFT: @{UInt64: AirdropFungibleTokenPool}

        init() {
            self.airdropsNFT <- {}
            self.airdropsFT <- {}
        }

        destroy() {
            destroy self.airdropsFT
            destroy self.airdropsNFT
        }

        // --- Getters - Public Interfaces ---

        // get all ids
        pub fun getIDs(isNFT: Bool): [UInt64] {
            if isNFT {
                return self.airdropsNFT.keys
            } else {
                return self.airdropsFT.keys
            }
        }

        pub fun borrowAirdropFungiblePool(id: UInt64): &{AirdropPoolPublic, AirdropFungiblePoolPublic} {
            return self.borrowAirdropFungiblePoolRef(id: id)
        }

        pub fun borrowAirdropNonFungiblePool(id: UInt64): &{AirdropPoolPublic, AirdropNonFungiblePoolPublic} {
            return self.borrowAirdropNonFungiblePoolRef(id: id)
        }

        // --- Getters - Private Interfaces ---

        // create a new airdrop pool
        pub fun createAirdropFungiblePool(
            _ display: AirdropPoolDisplay,
            provider: Capability<&{FungibleToken.Provider, FungibleToken.Balance}>,
            whitelist: {String: FungibleWhitelist}
        ): UInt64 {
            let pool <- create AirdropFungibleTokenPool(
                display,
                provider: provider,
                whitelist: whitelist
            )
            let id = pool.uuid
            self.airdropsFT[id] <-! pool

            emit FloidAirdropPoolCreated(
                owner: self.owner!.address,
                id: id,
                isNFT: false
            )
            return id
        }

        pub fun createAirdropNonFungiblePool(
            _ display: AirdropPoolDisplay,
            type: Type,
            collection: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>,
            whitelist: {String: NonFungibleWhitelist},
            totalQuota: UInt64,
            including: [UInt64],
            excluding: [UInt64],
        ): UInt64 {
            let pool <- create AirdropNonFungibleTokenPool(
                display,
                type: type,
                collection: collection,
                whitelist: whitelist,
                totalQuota: totalQuota,
                including: including,
                excluding: excluding,
            )
            let id = pool.uuid
            self.airdropsNFT[id] <-! pool

            emit FloidAirdropPoolCreated(
                owner: self.owner!.address,
                id: id,
                isNFT: true
            )
            return id
        }

        // borrow private reference
        pub fun borrowAirdropFungiblePoolRef(id: UInt64): &AirdropFungibleTokenPool {
            pre {
                self.airdropsFT[id] != nil: "Airdrop pool does not exist in the dashboard!"
            }
            return (&self.airdropsFT[id] as &AirdropFungibleTokenPool?)!
        }

        // borrow private reference
        pub fun borrowAirdropNonFungiblePoolRef(id: UInt64): &AirdropNonFungibleTokenPool {
            pre {
                self.airdropsNFT[id] != nil: "Airdrop pool does not exist in the dashboard!"
            }
            return (&self.airdropsNFT[id] as &AirdropNonFungibleTokenPool?)!
        }

        // --- Setters - Contract Only ---

        // --- Self Only ---
    }

    // ---- contract methods ----

    // create the AirdropDashboard resource
    pub fun createAirdropDashboard(): @AirdropDashboard {
        return <- create AirdropDashboard()
    }

    // get address ids binding to the address
    access(contract) fun getBindingAddressIDs(_ address: Address): [FloidUtils.AddressID] {
        let floid = Floid.borrowIdentifier(address)
        if floid == nil {
            return []
        }

        let abStore = floid!.borrowAddressBindingStore()
        if abStore == nil {
            return []
        }

        let bindings: [FloidUtils.AddressID] = abStore!.getBindedAddressIDs()
        return bindings
    }

    init() {
        // paths
        self.FloidAirdropDashboardStoragePath = /storage/FloidAirdropDashboardPath
        self.FloidAirdropDashboardPublicPath = /public/FloidAirdropDashboardPath

        emit ContractInitialized()
    }
}
