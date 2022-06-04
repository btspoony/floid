<template>
  <div class="py-4 text-lg">
    <p>You have generated a binding key:</p>
    <p class="pt-2 text-primary text-center font-bold">
      {{ currentMessage?.msg }}
    </p>
    <p class="pt-2">
      Expire:
      <WidgetExpireCooldown class="text-accent" :expire-at="currentMessage?.expireAt"
        @expire-changed="onExpireChanged" />
    </p>
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
