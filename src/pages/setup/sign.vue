<template>
  <div class="hero">
    <div class="hero-content gap-4 flex-col lg:flex-row text-center lg:text-left">
      <div class="flow-ball flex-none"></div>
      <div>
        <h1 class="text-4xl font-bold">Sign with Ethers</h1>
        <PartialSetupMessageDisplay />
        <EvmConnect :full="true" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const router = useRouter();
const currentMessage = useCurrentSetupMessage();
</script>
