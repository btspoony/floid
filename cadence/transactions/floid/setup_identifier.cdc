import Floid from "../../contracts/Floid.cdc"

transaction {

  prepare(acct: AuthAccount) {
    // SETUP Floid identifier resource, link public and private
    if acct.borrow<&Floid.FloidIdentifier>(from: Floid.FloidIdentifierStoragePath) == nil {
      acct.save(<- Floid.createIdentifier(), to: Floid.FloidIdentifierStoragePath)
      acct.link<&Floid.FloidIdentifier{Floid.FloidIdentifierPublic}>(Floid.FloidIdentifierPublicPath, target: Floid.FloidIdentifierStoragePath)
      acct.link<&Floid.FloidIdentifier{Floid.FloidIdentifierPrivate}>(Floid.FloidIdentifierPrivatePath, target: Floid.FloidIdentifierStoragePath)
    }
  }

  execute {
    log("Setup identifier.")
  }
}
