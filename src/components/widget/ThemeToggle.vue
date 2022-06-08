<template>
  <label class="swap swap-rotate hover:text-primary dark:hover:text-white focus:outline-none">
    <!-- this hidden checkbox controls the state -->
    <input v-model="isLight" type="checkbox" />
    <span class="sr-only">View ThemeToggle: {{ theme }}</span>
    <!-- volume on icon -->
    <SunIcon class="swap-off fill-current h-6 w-6" />
    <!-- volume off icon -->
    <MoonIcon class="swap-on fill-current h-6 w-6" />
  </label>
</template>

<script setup lang="ts">
import { SunIcon, MoonIcon } from "@heroicons/vue/outline";

const theme = useTheme();

onMounted(() => {
  if (
    localStorage.theme === "dark" ||
    (!("theme" in localStorage) &&
      window.matchMedia("(prefers-color-scheme: dark)").matches)
  ) {
    theme.value = "dark";
  } else {
    theme.value = "light";
  }
});

const isLight = computed({
  get(): boolean {
    return theme.value !== "dark";
  },
  set(value: boolean) {
    if (value && theme.value !== "light") {
      theme.value = "light";
      localStorage.setItem("theme", "light");
    } else if (!value && theme.value !== "dark") {
      theme.value = "dark";
      localStorage.setItem("theme", "dark");
    }
  },
});
</script>
