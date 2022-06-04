<template>
  <div class="hero">
    <div class="hero-content gap-4 flex-col lg:flex-row text-center lg:text-left">
      <div class="flow-ball flex-none"></div>
      <div>
        <h1 class="text-4xl font-bold">Initialize Floid</h1>
        <progress v-if="isOnMountedQuerying" class="progress progress-primary w-54"></progress>
        <template v-else>
          <template v-if="!!currentMessage">
            <PartialSetupMessagePanel />
            <button class="card-button" role="button" @click="nextStep">
              Next
              <ArrowSmRightIcon class="fill-current h-4 w-4" />
            </button>
          </template>
          <template v-else>
            <p class="py-4">Setup and create a binding key.</p>
            <FlowSubmitTransaction content="Initialize" :method="submitAction" @sealed="onTransactionSealed">
              <template #next>
                <button class="card-button" role="button" @click="nextStep">
                  Next
                  <ArrowSmRightIcon class="fill-current h-4 w-4" />
                </button>
              </template>
            </FlowSubmitTransaction>
          </template>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowSmRightIcon } from "@heroicons/vue/solid";
import type { TransactionReceipt } from "@onflow/fcl";
import { ExpirableMessage } from "~~/src/types/floid";

const router = useRouter();
const currentAccount = useFlowAccount();
const currentMessage = useCurrentSetupMessage();

const isOnMountedQuerying = ref(true);
const submitAction = ref<() => Promise<string>>(null);

// FIXME, remove mock
const mockMessage = new ExpirableMessage({
  msg: "hello world",
  expireAt: Date.now() + 600 * 1000,
});

onMounted(async () => {
  const app = useNuxtApp();

  const res =
    (await app.$scripts.abstoreGetLastPendingMessage(
      currentAccount.value?.addr
    )) ?? mockMessage;
  isOnMountedQuerying.value = false;
  if (res && res?.expireAt > Date.now()) {
    currentMessage.value = res;
  }

  // the button action
  submitAction.value = app.$transactions.abstoreInitAndGenerateKey;
});

function onTransactionSealed(tx: TransactionReceipt) {
  // FIXME, filter from events
  currentMessage.value = mockMessage;
}

function nextStep() {
  router.push("/setup/sign");
}
</script>
