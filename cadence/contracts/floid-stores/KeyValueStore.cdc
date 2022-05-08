/**

# The contract of Floid KeyValue store

*/

import FloidIdentifierStore from "../FloidIdentifierStore.cdc"

pub contract KeyValueStore: FloidIdentifierStore {

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/

    pub event FloidKeyValueStoreUpdated(owner: Address, key: String, valueType: String)

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    // A public interface to kv store
    pub resource interface PublicInterface {
        pub fun getStringValue(_ key: String): String?
        pub fun getBooleanValue(_ key: String): Bool?
        pub fun getIntegerValue(_ key: String): Integer?
        pub fun getFixedPointValue(_ key: String): FixedPoint?
    }

    // The resource of key value store
    pub resource Store: FloidIdentifierStore.StorePublic, PublicInterface {
        access(self) let kvStore: {String: AnyStruct}

        init() {
            self.kvStore = {}
        }

        // --- Getters - Public Interfaces ---

        pub fun getOwner(): Address {
            return self.owner!.address
        }

        pub fun getStringValue(_ key: String): String? {
            let ret = self.kvStore[key]
            if ret == nil || !ret.isInstance(Type<String>()) {
                return  nil
            } else {
                return ret as! String
            }
        }

        pub fun getBooleanValue(_ key: String): Bool? {
            let ret = self.kvStore[key]
            if ret == nil || !ret.isInstance(Type<Bool>()) {
                return  nil
            } else {
                return ret as! Bool
            }
        }

        pub fun getIntegerValue(_ key: String): Integer? {
            let ret = self.kvStore[key]
            if ret == nil || !ret.isInstance(Type<Integer>()) {
                return  nil
            } else {
                return ret as! Integer
            }
        }

        pub fun getFixedPointValue(_ key: String): FixedPoint? {
            let ret = self.kvStore[key]
            if ret == nil || !ret.isInstance(Type<FixedPoint>()) {
                return  nil
            } else {
                return ret as! FixedPoint
            }
        }

        // --- Setters - Resource Interfaces ---

        // set any value to the kv store
        pub fun setValue(_ key: String, value: AnyStruct) {
            self.kvStore[key] = value

            emit FloidKeyValueStoreUpdated(
                owner: self.getOwner(),
                key: key,
                valueType: value.getType().identifier
            )
        }

        // --- Setters - Contract Only ---

        // --- Self Only ---

    }

    // create a resource of KeyValue store
    pub fun createStore(): @Store {
      return <- create Store()
    }
}

