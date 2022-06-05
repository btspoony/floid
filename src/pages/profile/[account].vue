<template>
  <main class="max-w-full min-h-[88vh] pt-16 flex flex-col">
    <!-- Banner -->
    <div class="relative max-h-80 overflow-hidden">
      <div class="h-0 pb-[25%] bg-accent/20 dark:bg-accent/20">
        <!-- TODO add profile banner -->
      </div>
    </div>
    <!-- Head -->
    <div class="page-container flex">
      <div class="mb-4 -mt-10 sm:-mt-20 md:-mt-28 lg:-mt-40">
        <div :class="[
          'relative z-10 rounded-[50%] bg-base-100 shadow-lg',
          'w-[90px] h-[90px] basis-[90px] border-2',
          'sm:w-[120px] sm:h-[120px] sm:basis-[120px]',
          'lg:w-[180px] lg:h-[180px] lg:basis-[180px] lg:border-4',
        ]">
          <WidgetAvatar :address="pageAccount" />
        </div>
      </div>
    </div>
    <!-- Address or Name -->
    <div class="page-container flex">
      <div class="min-w-0 max-w-[90%] sm:max-w-[80%] lg:max-w-[60%]">
        <div class="m-0 text-primary font-semibold text-xl sm:text-2xl lg:text-3xl">
          <span class="break-words">{{ pageAccount }}</span>
        </div>
      </div>
    </div>
    <!-- Binded Address -->
    <!-- Collections -->
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
