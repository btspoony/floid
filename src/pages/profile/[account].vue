<template>
  <main class="max-w-full min-h-[88vh] pt-16">
    <div class="page-container">Profile</div>
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
