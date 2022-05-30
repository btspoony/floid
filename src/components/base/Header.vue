<template>
  <header :class="[
    'fixed inset-x-0 top-0 w-screen transition-transform bg-white dark:bg-base-200 z-50',
    scrollStatus.isOnTop || (!scrollStatus.isOnTop && scrollStatus.isScrollUp)
      ? `translate-y-0 ${!scrollStatus.isOnTop ? 'shadow-sm' : ''}`
      : 'shadow-none -translate-y-16 duration-400',
  ]" :style="`--tw-bg-opacity: ${Math.max(
  0,
  Math.min(1, Math.floor((scrollStatus.lastScrollY / 64) * 90) * 0.01)
)};`">
    <Disclosure v-slot="{ open }" class="container max-w-6xl mx-auto" as="nav">
      <div class="relative flex items-center justify-between h-16 px-4 sm:px-6 lg:px-8">
        <div class="absolute inset-y-0 left-0 flex items-center sm:hidden">
          <!-- Mobile menu button-->
          <DisclosureButton
            class="inline-flex items-center justify-center p-2 rounded-md hover:text-base-300 dark:hover:text-white focus:outline-none">
            <span class="sr-only">Open main menu</span>
            <MenuIcon v-if="!open" class="block h-6 w-6" aria-hidden="true" />
            <XIcon v-else class="block h-6 w-6" aria-hidden="true" />
          </DisclosureButton>
        </div>
        <div class="flex-1 flex items-center justify-center sm:items-stretch sm:justify-start">
          <NuxtLink class="flex-shrink-0 flex items-center" to="/">
            <img class="block dark:hidden h-8 w-auto" src="~/assets/image/logo-colored.svg?url" alt="Floid" />
            <img class="hidden dark:block h-8 w-auto" src="~/assets/image/logo-black.svg?url" alt="Floid" />
          </NuxtLink>
          <div class="hidden sm:block sm:ml-6">
            <div class="flex space-x-4">
              <NuxtLink v-for="item in navigation" :key="item.name" :to="item.to" :class="[
                'inline-block align-middle px-3 py-5 h-16 text-base font-medium',
                item.current
                  ? 'text-primary border-primary hover:text-primary-focus border-b-4'
                  : 'hover:text-secondary dark:text-base-content dark:hover:text-secondary',
              ]" :aria-current="item.current ? 'page' : undefined">
                {{ item.name }}</NuxtLink>
            </div>
          </div>
        </div>
        <div
          class="absolute inset-y-0 right-0 flex space-x-2 items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0">
          <ClientOnly>
            <WidgetThemeToggle />
            <WidgetConnect class="hidden sm:block" />
          </ClientOnly>
        </div>
      </div>

      <DisclosurePanel class="sm:hidden bg-white dark:bg-base-200">
        <div class="px-2 pt-2 pb-3 space-y-1">
          <NuxtLink v-for="item in navigation" :key="item.name" :to="item.to" :class="[
            'block px-3 py-2 text-primary text-base font-medium',
            item.current
              ? 'border-primary hover:text-primary-focus border-l-4'
              : 'hover:text-secondary dark:text-base-content dark:hover:text-secondary',
          ]" :aria-current="item.current ? 'page' : undefined">{{ item.name }}</NuxtLink>
          <div class="divider"></div>
          <div class="flex items-center justify-center">
            <ClientOnly>
              <WidgetConnect />
            </ClientOnly>
          </div>
        </div>
      </DisclosurePanel>
    </Disclosure>
  </header>
</template>

<script setup lang="ts">
import { Disclosure, DisclosureButton, DisclosurePanel } from "@headlessui/vue";
import { MenuIcon, XIcon } from "@heroicons/vue/outline";

const scrollStatus = useScrollStatus();
const route = useRoute();

const navigation = reactive([
  // { name: "Airdrops", to: "/airdrops/create", current: false },
  { name: "About", to: "/#about", current: false },
]);

watchEffect(
  () => {
    navigation.forEach((element) => {
      let path = route.path + (route.hash || "");
      element.current = element.to === path;
    });
  },
  { flush: "post" }
);

function handleScroll(event) {
  let last = scrollStatus.value.lastScrollY;

  scrollStatus.value.isOnTop = last < 64;
  scrollStatus.value.isScrollUp = last - window.scrollY > 0;
  scrollStatus.value.lastScrollY = window.scrollY;
}

onBeforeMount(() => {
  window.addEventListener("scroll", handleScroll, { passive: true });
});

onBeforeUnmount(() => {
  window.removeEventListener("scroll", handleScroll);
});
</script>
