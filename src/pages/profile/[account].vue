<template>
  <main class="max-w-full">
    <section class="hero min-h-screen">
      <div class="page-container">Profile</div>
    </section>
  </main>
</template>

<script setup lang="ts">
import type { AddressID } from "../../types/floid";

const route = useRoute();
const currentAccount = useFlowAccount();

definePageMeta({
  title: "Profile",
});

// check if current is self
const isSelf = computed(() => {
  return (
    currentAccount.value?.loggedIn &&
    currentAccount.value?.addr === route.params.account
  );
});

onMounted(async () => {
  const app = useNuxtApp();

  let bindingAddrs: Array<AddressID>;
  try {
    bindingAddrs = await app.$scripts.abstoreGetBindedAddressIDs(
      currentAccount.value?.addr
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
