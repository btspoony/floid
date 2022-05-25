<template>
  <div v-if="current?.loggedIn">
    <span>{{ current?.addr ?? "No Address" }}</span>
    <button class="btn btn-sm btn-circle btn-ghost" @click="logout">
      <LogoutIcon />
    </button>
  </div>
  <button v-else class="btn btn-sm btn-primary" @click="login">
    Connect Wallet
  </button>
</template>

<script setup lang="ts">
import { LogoutIcon } from "@heroicons/vue/outline";

const current = useFlowAccount();

watchEffect(() => {
  try {
    if (process.client) {
      const { $fcl } = useNuxtApp();
      $fcl.currentUser.subscribe((user) => {
        current.value = user;
      });
    }
  } catch (e) {
    console.error(e);
  }
});

function login() {
  const { $fcl } = useNuxtApp();
  $fcl.authenticate();
}

function logout() {
  const { $fcl } = useNuxtApp();
  $fcl.unauthenticate();
}
</script>
