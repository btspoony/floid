/**

# The contract of Floid Utilities

*/

pub contract FloidUtils {

    // --- expirable key and crypto verify ---

    pub struct ExpirableMessage {
        pub let msg: String
        pub let expireAt: UFix64

        init(_ msg: String, expire: UFix64) {
            self.msg = msg
            self.expireAt = expire
        }
    }

    // The struct of verifiable messages
    pub struct VerifiableMessages {
        pub let maxLengh: Int
        access(self) let messages: [ExpirableMessage]

        init(_ maxLengh: Int?) {
            self.messages = []
            self.maxLengh = maxLengh ?? 5
        }

        // get the last verification message
        pub fun getLastMessage(): ExpirableMessage? {
            if self.messages.length > 0 {
                return self.messages[0]
            }
            return nil
        }

        // check if the message is valid
        pub fun isMessageValid(message: String): Bool {
            let now = getCurrentBlock().timestamp
            var isValid = false

            for one in self.messages {
                if message == one.msg && now <= one.expireAt {
                    isValid = true
                    break
                }
            }
            return isValid
        }

        // generate a new message with expire time
        pub fun generateNewMessage(expireIn: UFix64, prefix: String?): String {
            post {
                self.messages.length <= self.maxLengh: "Too many messages"
            }

            let block = getCurrentBlock()
            let blockId = block.id
            let blockTime = block.timestamp

            let idArr: [UInt8] = []
            var i = 0
            while i < 16 {
                idArr.append(blockId[Int(unsafeRandom() % 32)]!)
                i = i + 1
            }

            let keyString = (prefix ?? "").concat(String.encodeHex(idArr))
            let key = ExpirableMessage(keyString, expire: blockTime + expireIn)

            self.messages.insert(at: 0, key)
            // no more than 5 keys
            if self.messages.length > self.maxLengh {
                self.messages.removeLast()
            }

            return keyString
        }

        // verify a message and remove messages which expired
        // if not invalid, do nothing
        pub fun verifyMessageSignatureAndCleanup(
            message: String,
            messagePrefix: String?,
            hashTag: String?,
            hashAlgorithm: HashAlgorithm,
            publicKey: [UInt8],
            signatureAlgorithm: SignatureAlgorithm,
            signature: [UInt8],
        ): Bool {
            // verify signature
            let messageToVerify = (messagePrefix ?? "").concat(message)
            let keyToVerify = PublicKey(publicKey: publicKey, signatureAlgorithm: signatureAlgorithm)
            let isValid = keyToVerify.verify(
                signature: signature,
                signedData: messageToVerify.utf8,
                domainSeparationTag: hashTag ?? "",
                hashAlgorithm: hashAlgorithm
            )
            if !isValid {
                return false
            }

            // if valid, remove key data
            let now = getCurrentBlock().timestamp
            let expiredIds: [Int] = []
            for idx, one in self.messages {
                if message == one.msg || now > one.expireAt {
                    expiredIds.append(idx)
                }
            }
            for idx in expiredIds {
                self.messages.remove(at: idx)
            }
            return true
        }
    }

    // enum for supported chain type
    pub enum SupportedChainType: UInt8 {
        pub case EVM_COMPATIBLE
    }

    // Struct of Third party Address ID
    pub struct AddressID {
        pub let chain: SupportedChainType
        pub let address: String
        pub let referID: String?

        init(_ chain: SupportedChainType, address: String, referID: String?) {
            self.chain = chain
            self.address = address
            self.referID = referID
        }

        // get the identify string of chain id
        pub fun getChainID(): String {
            var chainID: String = "chainstd"
            switch self.chain {
            case SupportedChainType.EVM_COMPATIBLE:
                chainID = "eip155"
                break
            }
            return chainID.concat(":").concat(self.referID ?? "<x>")
        }

        // get the identify string of the address
        pub fun toString(): String {
            return self.getChainID().concat(":").concat(self.address)
        }
    }

    // parse Address id from string
    access(contract) fun parseAddressID(str: String): AddressID? {
        let parseIdx: [Int; 2] = [-1,-1]
        var i = 0
        var cnt = 0
        while i < str.length {
            if str[i] == ":" {
                if cnt >= 2 {
                    return nil
                }
                parseIdx[cnt] = i
                cnt = cnt + 1
            }
            i = i + 1
        }
        if parseIdx[0] < 0 || parseIdx[1] < 0 {
            return nil
        }

        let chainID = str.slice(from: 0, upTo: parseIdx[0])
        var chain: SupportedChainType? = nil
        switch chainID {
        case "eip155":
            chain = SupportedChainType.EVM_COMPATIBLE
            break
        }
        if chain == nil {
            return nil
        }
        return AddressID(chain!, address: str.slice(from: parseIdx[1], upTo: str.length), referID: str.slice(from: parseIdx[0], upTo: parseIdx[1]))
    }
}
