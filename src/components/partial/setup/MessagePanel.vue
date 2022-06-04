<template>
  <div class="flex flex-col gap-2 py-4 text-lg">
    <p>You have generated a binding key:</p>
    <p class="text-primary text-center font-bold">
      {{ currentMessage?.msg }}
    </p>
    <p>
      Expire:
      <WidgetExpireCooldown class="text-accent" :expire-at="currentMessage?.expireAt"
        @expire-changed="onExpireChanged" />
    </p>
    <template v-if="currentMsgSignature !== null">
      <div class="divider">Signature</div>
      <p class="text-primary text-sm max-w-[320px] break-words">
        {{ currentMsgSignature }}
      </p>
    </template>
  </div>
</template>

<script setup lang="ts">
const currentMessage = useCurrentSetupMessage();
const currentMsgSignature = useCurrentSetupMessageSignature();

// when current setup message changed,
// cleanup message signature
watch(currentMessage, (newVal, oldVal) => {
  currentMsgSignature.value = null;
});

// when current message expired,
// cleanup message
function onExpireChanged(value: boolean) {
  if (value) {
    currentMessage.value = null;
  }
}
</script>
