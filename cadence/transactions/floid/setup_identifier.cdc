import Floid from "../../contracts/Floid.cdc"
import FloidInterface from "../../contracts/FloidInterface.cdc"
import MetadataViews from "../../contracts/core/MetadataViews.cdc"

transaction {

  prepare(acct: AuthAccount) {
    // SETUP Floid identifier resource, link public and private
    if acct.borrow<&Floid.Identifier>(from: Floid.FloidStoragePath) == nil {
      acct.save(<- Floid.createIdentifier(), to: Floid.FloidStoragePath)
      acct.link<&Floid.Identifier{Floid.FloidPublic, FloidInterface.IdentifierPublic, MetadataViews.Resolver}>
        (Floid.FloidPublicPath, target: Floid.FloidStoragePath)
      acct.link<&Floid.Identifier{Floid.FloidPrivate}>
        (Floid.FloidPrivatePath, target: Floid.FloidStoragePath)
    }
  }

  execute {
    log("Setup identifier.")
  }
}
