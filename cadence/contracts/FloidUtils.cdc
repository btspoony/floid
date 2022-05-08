
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
        access(self) let messages: [ExpirableMessage]
        access(self) let maxLengh: Int

        init(_ maxLengh: Int?) {
            self.messages = []
            self.maxLengh = maxLengh ?? 5
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
        pub fun generateNewMessage(expireIn: UFix64): String {
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

            let keyString = String.encodeHex(idArr)
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
                signedData: messageToVerify.decodeHex(),
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

}
