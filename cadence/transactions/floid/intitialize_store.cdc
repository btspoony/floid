import Floid from "../../contracts/Floid.cdc"
import KeyValueStore from "../../contracts/floid-stores/KeyValueStore.cdc"
import AddressBindingStore from "../../contracts/floid-stores/AddressBindingStore.cdc"

transaction(
  type: UInt8
) {

  let user: &Floid.FloidIdentifier

  prepare(acct: AuthAccount) {
    // SETUP Floid identifier resource, link public and private
    if acct.borrow<&Floid.FloidIdentifier>(from: Floid.FloidIdentifierStoragePath) == nil {
      acct.save(<- Floid.createIdentifier(), to: Floid.FloidIdentifierStoragePath)
      acct.link<&Floid.FloidIdentifier{Floid.FloidIdentifierPublic}>(Floid.FloidIdentifierPublicPath, target: Floid.FloidIdentifierStoragePath)
      acct.link<&Floid.FloidIdentifier{Floid.FloidIdentifierPrivate}>(Floid.FloidIdentifierPrivatePath, target: Floid.FloidIdentifierStoragePath)
    }

    self.user = acct.borrow<&Floid.FloidIdentifier>(from: Floid.FloidIdentifierStoragePath)
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
