import Floid from 0xFloid
import AddressBindingStore from 0xFloid
import FloidUtils from 0xFloid

transaction(
  address: String,
  message: String,
  publicKey: String,
  signature: String,
) {

  let store: &AddressBindingStore.Store

  prepare(acct: AuthAccount) {
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
    let addrId = FloidUtils.AddressID(
      FloidUtils.SupportedChainType.EVM_COMPATIBLE,
      address: address,
      referID: nil
    )

    self.store.verifyBindingMessage(
        addrId,
        message: message,
        hashAlgorithm: HashAlgorithm.KECCAK_256,
        publicKey: publicKey,
        signatureAlgorithm: SignatureAlgorithm.ECDSA_secp256k1,
        signature: signature,
    )

    log("VerifyBindingMessage succeed")
  }
}
