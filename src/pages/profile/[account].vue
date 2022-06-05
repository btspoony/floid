<template>
  <main class="max-w-full min-h-[88vh] pt-16 flex flex-col">
    <!-- Banner -->
    <div class="relative max-h-80 overflow-hidden">
      <div class="h-0 pb-[25%] bg-primary-content/30">
        <!-- TODO add profile banner -->
      </div>
    </div>
    <!-- Head -->
    <div class="page-container"></div>
  </main>
</template>

<script setup lang="ts">
import type { AddressID } from "../../types/floid";

definePageMeta({
  title: "Profile",
});

const route = useRoute();
const currentAccount = useFlowAccount();

// page account
const pageAccount = computed<string>(() => route.params.account as string);

// check if current is self
const isSelf = computed(() => {
  return (
    currentAccount.value?.loggedIn &&
    currentAccount.value?.addr === pageAccount.value
  );
});

onMounted(async () => {
  const app = useNuxtApp();

  let bindingAddrs: Array<AddressID>;
  try {
    bindingAddrs = await app.$scripts.abstoreGetBindedAddressIDs(
      pageAccount.value
    );
  } catch (err) {
    console.error(err);
    bindingAddrs = [];
  }

  if (isSelf.value && bindingAddrs.length === 0) {
    const router = useRouter();
    // FIXME no redirect
    // router.push("/setup");
  }
});
</script>
