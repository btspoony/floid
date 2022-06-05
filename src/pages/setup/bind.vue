<template>
  <div class="flex-auto max-w-[320px]">
    <h1 class="text-4xl font-bold">Bind to Floid</h1>
    <EvmAddressDisplay class="mt-4" :locked="true" />
    <PartialSetupMessagePanel v-if="!transactionSent" />
    <div v-else class="divider">Please Wait</div>
    <FlowSubmitTransaction ref="compSubmitTx" :method="verifyBindingKey" @sealed="onTransactionSealed">
      <LinkIcon class="fill-current h-4 w-4 pr-1" />
      Verify And Bind
      <template #next>
        <button v-if="!transactionSucceed" class="card-button" role="button" @click="resetProcess">
          <RefreshIcon class="fill-current h-4 w-4 pr-1" />
          Reset
        </button>
      </template>
    </FlowSubmitTransaction>
  </div>
</template>

<script setup lang="ts">
import { ethers } from "ethers";
import { ArrowSmRightIcon, LinkIcon, RefreshIcon } from "@heroicons/vue/solid";
import type { TransactionReceipt } from "@onflow/fcl";
import FlowSubmitTransaction from "~/components/flow/SubmitTransaction.vue";

// use state
const evmAccount = useEVMAccount();
const currentMessage = useCurrentSetupMessage();
const currentMsgSignature = useCurrentSetupMessageSignature();

// internal ref
const transactionSent = ref(false);
const transactionSucceed = ref(false);

// component ref
const compSubmitTx = ref<InstanceType<typeof FlowSubmitTransaction> | null>(
  null
);

async function verifyBindingKey(): Promise<string> {
  const app = useNuxtApp();
  // from state
  const evmSigner = toRaw(evmAccount.value);
  const message = toRaw(currentMessage.value).msg;
  const signature = toRaw(currentMsgSignature.value);
  // public key
  const messageHash = ethers.utils.hashMessage(message);
  const messageHashBytes = ethers.utils.arrayify(messageHash);
  const publicKey = ethers.utils.recoverPublicKey(messageHashBytes, signature);

  function trimZeroX(str: string) {
    return str.startsWith("0x") ? str.slice(2) : str;
  }

  // execute transaction
  const txid = await app.$transactions.abstoreVerifyBindingKey(
    await evmSigner.getAddress(),
    message,
    trimZeroX(publicKey),
    trimZeroX(signature)
  );

  // update transaction sent
  transactionSent.value = true;

  return txid;
}

function onTransactionSealed(tx: TransactionReceipt) {
  const success = false;
  // FIXME, filter from events
  if (!success) {
    transactionSucceed.value = success;
  } else {
    nextStep();
  }
}

function resetProcess() {
  transactionSent.value = false;
  transactionSucceed.value = false;
  // execute reset
  compSubmitTx.value?.resetComponent();
}

function nextStep() {
  const router = useRouter();
  const flowAccount = useFlowAccount();

  const flowAddr = flowAccount.value?.addr;
  router.push(`/profile/${flowAddr}`);
}
</script>
