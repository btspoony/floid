<template>
  <div class="card min-w-40 max-w-full flex items-center">
    <progress class="progress progress-secondary w-40"></progress>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  txid: string;
}>();

onMounted(() => {
  // TODO
});
</script>
