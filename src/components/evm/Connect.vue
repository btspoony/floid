<template>
  <div></div>
</template>

<script setup lang="ts">
import { LogoutIcon } from "@heroicons/vue/solid";

interface Props {
  full?: boolean;
}
const props = withDefaults(defineProps<Props>(), {
  full: false,
});

const evmAccount = useEvmAccount();

onMounted(() => {
  // TODO
});
</script>
