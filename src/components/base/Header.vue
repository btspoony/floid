<template>
  <header class="max-w-full bg-base-100 shadow-md">
    <Disclosure v-slot="{ open }" as="nav" class="container max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="relative flex items-center justify-between h-16">
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
            <img class="block dark:hidden h-8 w-auto" src="~/assets/image/logo-colored.svg" alt="Floid" />
            <img class="hidden dark:block h-8 w-auto" src="~/assets/image/logo-black.svg" alt="Floid" />
          </NuxtLink>
          <div class="hidden sm:block sm:ml-6">
            <div class="flex space-x-4">
              <a v-for="item in navigation" :key="item.name" :href="item.href" :class="[
                'inline-block align-middle px-3 py-5 h-16 text-primary text-base font-medium',
                item.current
                  ? 'border-primary hover:text-primary-focus border-b-4'
                  : 'hover:text-secondary dark:text-base-content dark:hover:text-secondary',
              ]" :aria-current="item.current ? 'page' : undefined">
                {{ item.name }}</a>
            </div>
          </div>
        </div>
        <div class="absolute inset-y-0 right-0 flex items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0">
          <ClientOnly>
            <WidgetThemeToggle />
          </ClientOnly>
        </div>
      </div>

      <DisclosurePanel class="sm:hidden">
        <div class="px-2 pt-2 pb-3 space-y-1">
          <DisclosureButton v-for="item in navigation" :key="item.name" as="a" :href="item.href" :class="[
            'block px-3 py-2 text-primary text-base font-medium',
            item.current
              ? 'border-primary hover:text-primary-focus border-l-4'
              : 'hover:text-secondary dark:text-base-content dark:hover:text-secondary',
          ]" :aria-current="item.current ? 'page' : undefined">{{ item.name }}</DisclosureButton>
        </div>
      </DisclosurePanel>
    </Disclosure>
  </header>
</template>

<script setup lang="ts">
import {
  Disclosure,
  DisclosureButton,
  DisclosurePanel,
  Menu,
  MenuButton,
  MenuItem,
  MenuItems,
} from "@headlessui/vue";
import { MenuIcon, XIcon } from "@heroicons/vue/outline";

const navigation = [
  { name: "Airdrops", href: "#", current: false },
  { name: "About", href: "#", current: false },
];
</script>
