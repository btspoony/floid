import Floid from "../../contracts/Floid.cdc"
import FloidInterface from "../../contracts/FloidInterface.cdc"
import MetadataViews from "../../contracts/core/MetadataViews.cdc"
import AddressBindingStore from "../../contracts/floid-stores/AddressBindingStore.cdc"

transaction() {

  let store: &AddressBindingStore.Store

  prepare(acct: AuthAccount) {
    // SETUP Floid identifier resource, link public and private
    if acct.borrow<&Floid.Identifier>(from: Floid.FloidStoragePath) == nil {
      acct.save(<- Floid.createIdentifier(acct: acct.address), to: Floid.FloidStoragePath)
      acct.link<&Floid.Identifier{Floid.FloidPublic, FloidInterface.IdentifierPublic, MetadataViews.Resolver}>
        (Floid.FloidPublicPath, target: Floid.FloidStoragePath)
      acct.link<&Floid.Identifier{Floid.FloidPrivate}>
        (Floid.FloidPrivatePath, target: Floid.FloidStoragePath)
    }

    let user = acct.borrow<&Floid.Identifier>(from: Floid.FloidStoragePath)
      ?? panic("Failed to borrow floid identifier")

    // ENSURE address binding stores
    var store = user.borrowAddressBindingStoreFull()
    // create store first
    if store == nil {
        user.initializeStore(store: <- AddressBindingStore.createStore())
        store = user.borrowAddressBindingStoreFull()
    }
    self.store = store ?? panic("Failed to borrow address binding store.")
  }

  execute {
    log("Initialized store.")
  }
}
