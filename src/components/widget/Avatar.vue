<template>
  <div class="relative rounded-full w-full h-full">
    <img v-if="!!address" :src="avatarUrl" :alt="address" class="rounded-full" />
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  address?: string;
}>();

const avatarUrl = computed(() => {
  const config = useRuntimeConfig();
  return encodeURI(
    `${config.public.avatarUrl.trim().replace(/\/$/, "")}/${props.address}.svg`
  );
});
</script>
