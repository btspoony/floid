<template>
  <div class="hero">
    <div class="hero-content gap-4 flex-col lg:flex-row text-center lg:text-left">
      <div class="flow-ball flex-none"></div>
      <div>
        <h1 class="text-4xl font-bold">Initialize Floid</h1>
        <progress v-if="isOnMountedQuerying" class="progress progress-primary w-54"></progress>
        <template v-else>
          <template v-if="!!currentMessage">
            <p class="pt-6">You have generated a binding key:</p>
            <p class="pt-2 text-primary text-lg">{{ currentMessage?.msg }}</p>
            <p class="pt-2 mb-4 text-lg">
              Expire:
              <WidgetExpireCooldown class="text-lg text-accent" :expire-at="currentMessage?.expireAt"
                @expire-changed="onExpireChanged" />
            </p>
            <button class="btn btn-sm btn-primary btn-block" @click="nextStep">
              Next
              <ArrowSmRightIcon class="fill-current h-4 w-4" />
            </button>
          </template>
          <template v-else>
            <p class="py-6">Setup and create a binding key.</p>
            <FlowSubmitTransaction content="Initialize" :method="submitAction" />
          </template>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowSmRightIcon } from "@heroicons/vue/solid";
// import { ExpirableMessage } from "~~/src/types/floid";

const router = useRouter();
const currentAccount = useFlowAccount();
const currentMessage = useCurrentSetupMessage();

const isOnMountedQuerying = ref(true);
const submitAction = ref<() => Promise<string>>(null);

onMounted(async () => {
  const app = useNuxtApp();

  const res = await app.$scripts.abstoreGetLastPendingMessage(
    currentAccount.value?.addr
  );
  isOnMountedQuerying.value = false;
  if (res && res?.expireAt > Date.now()) {
    currentMessage.value = res;
  }

  // the button action
  submitAction.value = app.$transactions.abstoreInitAndGenerateKey;
});

function onExpireChanged(value: boolean) {
  if (value) {
    currentMessage.value = null;
  }
}

function nextStep() {
  router.push("/setup/sign");
}
</script>
