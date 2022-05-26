<template>
  <div>
    <div v-if="current?.loggedIn"
      class="flex items-center justify-between rounded-full bg-primary text-primary-content">
      <span class="flex-auto h-4 leading-4 pl-4 pr-1 font-medium">
        {{ current?.addr ?? "No Address" }}
      </span>
      <button class="flex-none btn btn-sm btn-circle btn-primary" @click="logout">
        <LogoutIcon class="fill-current h-4 w-4" />
      </button>
    </div>
    <button v-else class="btn btn-sm btn-primary" @click="login">
      Connect Wallet
    </button>
  </div>
</template>

<script setup lang="ts">
import { LogoutIcon } from "@heroicons/vue/solid";

const current = useFlowAccount();

onMounted(() => {
  const { $fcl } = useNuxtApp();
  $fcl.currentUser.subscribe((user) => {
    current.value = user;
  });
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
