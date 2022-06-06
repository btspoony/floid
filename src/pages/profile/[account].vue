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
      <div class="mb-4 -mt-10 sm:-mt-20 lg:-mt-40">
        <div :class="[
          'relative z-10 rounded-[50%] bg-base-100 shadow-lg',
          'w-[90px] h-[90px] basis-[90px] border-2',
          'sm:w-[120px] sm:h-[120px] sm:basis-[120px]',
          'lg:w-[180px] lg:h-[180px] lg:basis-[180px] lg:border-4',
        ]">
          <WidgetAvatar :address="pageAccount" />
        </div>
      </div>
      <!-- TODO: smaller then sm account info -->
    </div>
    <!-- Address or Name -->
    <div class="page-container flex justify-between mb-3">
      <div class="min-w-0 max-w-[90%] sm:max-w-[80%] lg:max-w-[60%]">
        <div class="m-0 font-semibold text-xl sm:text-2xl lg:text-3xl">
          <span class="break-words">{{ pageAccount }}</span>
        </div>
      </div>
      <!-- TODO: greator then sm account info -->
    </div>
    <div class="page-container flex flex-col gap-3">
      <!-- Tabs -->
      <div class="tabs">
        <NuxtLink v-for="tab in tabs" :key="tab.label" :class="[
          'tab tab-lg font-semibold',
          currentTab === tab.page
            ? 'text-primary border-b-4 border-primary'
            : '',
        ]" :to="`/profile/${pageAccount}/${tab.page}`">
          {{ tab.label }}
        </NuxtLink>
      </div>
      <NuxtPage />
    </div>
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

const tabs = reactive([
  { label: "Portfolio", page: "portfolio" },
  { label: "NFT", page: "nft" },
]);
const currentTab = ref("");

watchEffect(() => {
  const paths = route.path.split("/");
  if (!route.path.startsWith("/profile")) return;
  currentTab.value = paths[paths.length - 1];
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
