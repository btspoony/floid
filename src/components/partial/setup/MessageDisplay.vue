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

function onExpireChanged(value: boolean) {
  if (value) {
    currentMessage.value = null;
  }
}
</script>
