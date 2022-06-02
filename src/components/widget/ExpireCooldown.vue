<template>
  <div class="flex text-center">
    <span v-if="!datetime.expired" class="countdown font-mono">
      <span :style="`--value: ${datetime.h}`"></span>:
      <span :style="`--value: ${datetime.m}`"></span>:
      <span :style="`--value: ${datetime.s}`"></span>
    </span>
    <span v-else>EXPIRED</span>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  expireAt: number;
}>();

const now = ref(Date.now());

const datetime = computed(() => {
  const ret = { h: 0, m: 0, s: 0, expired: false };
  if (props.expireAt < now.value) {
    ret.expired = true;
    return ret;
  }
  const rest = new Date(props.expireAt - now.value);
  ret.h = rest.getDate() * 24 + rest.getHours();
  ret.m = rest.getMinutes();
  ret.s = rest.getSeconds();

  return ret;
});

let intervalId;
onMounted(() => {
  intervalId = setInterval(() => {
    now.value = Date.now();
  }, 1000);
});

onBeforeUnmount(() => {
  if (intervalId) {
    clearInterval(intervalId);
  }
});
</script>
