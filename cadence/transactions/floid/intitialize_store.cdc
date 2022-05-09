import Floid from "../../contracts/Floid.cdc"
import FloidInterface from "../../contracts/FloidInterface.cdc"
import MetadataViews from "../../contracts/core/MetadataViews.cdc"
import KeyValueStore from "../../contracts/floid-stores/KeyValueStore.cdc"
import AddressBindingStore from "../../contracts/floid-stores/AddressBindingStore.cdc"

transaction(
  type: UInt8
) {

  let user: &Floid.Identifier

  prepare(acct: AuthAccount) {
    // SETUP Floid identifier resource, link public and private
    if acct.borrow<&Floid.Identifier>(from: Floid.FloidStoragePath) == nil {
      acct.save(<- Floid.createIdentifier(acct.address), to: Floid.FloidStoragePath)
      acct.link<&Floid.Identifier{Floid.FloidPublic, FloidInterface.IdentifierPublic, MetadataViews.Resolver}>
        (Floid.FloidPublicPath, target: Floid.FloidStoragePath)
      acct.link<&Floid.Identifier{Floid.FloidPrivate}>
        (Floid.FloidPrivatePath, target: Floid.FloidStoragePath)
    }

    self.user = acct.borrow<&Floid.Identifier>(from: Floid.FloidStoragePath)
      ?? panic("Failed to borrow floid identifier")
  }

  execute {
    let type = Floid.GenericStoreType(rawValue: type) ?? panic("Invalid store type")
    if type == Floid.GenericStoreType.KVStore {
      self.user.initializeStore(store: <- KeyValueStore.createStore())
    } else if type == Floid.GenericStoreType.AddressBinding {
      self.user.initializeStore(store: <- AddressBindingStore.createStore())
    } else {
      log("Unmatched type")
      return
    }

    log("Initialized store.")
  }
}
