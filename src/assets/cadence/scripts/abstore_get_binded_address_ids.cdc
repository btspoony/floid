import Floid from 0xFloid
import AddressBindingStore from 0xFloid
import FloidUtils from 0xFloid

pub fun main(acct: Address): [FloidUtils.AddressID] {
  let floid = Floid.borrowIdentifier(acct) ?? panic("Failed to borrow Floid.")
  let abstore = floid.borrowAddressBindingStore() ?? panic("Failed to borrow Floid AddressBinding Store.")
  return abstore.getBindedAddressIDs()
}
