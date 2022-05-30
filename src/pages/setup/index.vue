<template>
  <div class="hero">
    <div class="hero-content gap-4 flex-col lg:flex-row text-center lg:text-left">
      <div class="flow-ball flex-none"></div>
      <div>
        <h1 class="text-4xl font-bold">Flow Wallet</h1>
        <p class="py-6">Connect to your non-custodial flow wallet.</p>
        <WidgetConnect :full="true" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts"></script>
