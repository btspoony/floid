<template>
  <button type="button" class="p-1 rounded-full hover:text-primary dark:hover:text-white focus:outline-none"
    @click="toggle">
    <span class="sr-only">View ThemeToggle: {{ theme }}</span>
    <SunIcon v-if="theme === 'dark'" class="h-6 w-6" />
    <MoonIcon v-else class="h-6 w-6" />
  </button>
</template>

<script setup>
import { SunIcon, MoonIcon } from "@heroicons/vue/outline";

const theme = useTheme();

watchEffect(() => {
  if (process.client) {
    if (
      localStorage.theme === "dark" ||
      (!("theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      theme.value = "dark";
    } else {
      theme.value = "light";
    }
  }
});

function toggle(event) {
  if (theme.value === "dark") {
    theme.value = "light";
    localStorage.setItem("theme", "light");
  } else {
    theme.value = "dark";
    localStorage.setItem("theme", "dark");
  }
}
</script>
