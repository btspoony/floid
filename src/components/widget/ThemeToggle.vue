<template>
  <label class="swap swap-rotate hover:text-primary dark:hover:text-white focus:outline-none">
    <!-- this hidden checkbox controls the state -->
    <input v-model="isLight" type="checkbox" />
    <span class="sr-only">View ThemeToggle: {{ isDark ? "dark" : "light" }}</span>
    <!-- volume on icon -->
    <SunIcon class="swap-off fill-current h-6 w-6" />
    <!-- volume off icon -->
    <MoonIcon class="swap-on fill-current h-6 w-6" />
  </label>
</template>

<script setup lang="ts">
import { useDark, useToggle } from "@vueuse/core";
import { SunIcon, MoonIcon } from "@heroicons/vue/outline";

const isDark = useDark({
  attribute: "data-theme",
  valueDark: "forest",
  valueLight: "floid",
});

const isSharedDark = useSharedDark();
watchEffect(
  () => {
    isSharedDark.value = isDark.value;
  },
  { flush: "sync" }
);

const toggleDark = useToggle(isDark);

const isLight = computed({
  get(): boolean {
    return isDark.value;
  },
  set(value: boolean) {
    toggleDark(value);
  },
});
</script>
