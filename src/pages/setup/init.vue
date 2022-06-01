<template>
  <div class="hero">
    <div class="hero-content gap-4 flex-col lg:flex-row text-center lg:text-left">
      <div class="flow-ball flex-none"></div>
      <div>
        <h1 class="text-4xl font-bold">Initialize Floid</h1>
        <p class="py-6">Setup and create a binding key.</p>

        <button :class="['btn btn-sm btn-primary btn-block']" @click="submit">
          Initialize
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
function submit() {
  const { $fcl } = useNuxtApp();
}
</script>
