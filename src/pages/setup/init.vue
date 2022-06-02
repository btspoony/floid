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
            <p class="py-2 text-lg">{{ currentMessage.msg }}</p>
            <p class="py-2 text-lg">
              ExpireIn:
              <WidgetExpireCooldown class="text-lg" :expire-at="currentMessage.expireAt" />
            </p>
          </template>
          <p class="py-6">Setup and create a binding key.</p>

          <button :class="['btn btn-sm btn-primary btn-block']" @click="submit">
            Initialize
          </button>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const isOnMountedQuerying = ref(true);
const currentMessage = useCurrentSetupMessage();
const currentAccount = useFlowAccount();

onMounted(async () => {
  const app = useNuxtApp();

  const res = await app.$scripts.abstoreGetLastPendingMessage(
    currentAccount.value?.addr
  );
  isOnMountedQuerying.value = false;
  currentMessage.value = res;
});

function submit() {
  const app = useNuxtApp();

  // app.$scripts.abstoreGetLastPendingMessage
}
</script>
