<template>
  <div class="flex-auto max-w-[320px]">
    <h1 class="text-4xl font-bold">Sign with Ethers</h1>
    <EvmConnect class="mt-4" :full="true" />
    <PartialSetupMessagePanel />
    <template v-if="isValid && evmAccount !== null">
      <button class="card-button" @click="signMessage">Sign Message</button>
    </template>
  </div>
</template>

<script setup lang="ts">
const router = useRouter();
const evmAccount = useEVMAccount();
const currentMessage = useCurrentSetupMessage();
const currentMsgSignature = useCurrentSetupMessageSignature();

const isValid = computed(() => {
  const msg = currentMessage.value;
  return msg && msg.expireAt > Date.now() && evmAccount.value !== null;
});

async function signMessage() {
  const msgToSign = currentMessage.value?.msg;
  if (!msgToSign) {
    console.error("no message to sign.");
    return;
  }
  const sig = await toRaw(evmAccount.value).signMessage(msgToSign);

  if (sig) {
    currentMsgSignature.value = sig;
    router.push("/setup/bind");
  }
}
</script>
