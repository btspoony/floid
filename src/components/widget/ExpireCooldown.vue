<template>
  <div class="inline-block text-center">
    <span v-if="!datetime.expired" class="countdown font-mono">
      <span :style="`--value: ${datetime.h}`"></span>:
      <span :style="`--value: ${datetime.m}`"></span>:
      <span :style="`--value: ${datetime.s}`"></span>
    </span>
    <span v-else>EXPIRED</span>
  </div>
</template>

<script setup lang="ts">
const props = withDefaults(
  defineProps<{
    expireAt: number;
  }>(),
  { expireAt: Date.now() }
);

const emit = defineEmits<{
  (e: "expireChanged", id: boolean): void;
}>();

const now = ref(Date.now());

const datetime = computed(() => {
  const ret = { h: 0, m: 0, s: 0, expired: false };
  if (props.expireAt < now.value) {
    ret.expired = true;
    return ret;
  }
  const rest = new Date(props.expireAt - now.value);
  ret.h = rest.getUTCHours();
  ret.m = rest.getUTCMinutes();
  ret.s = rest.getUTCSeconds();

  return ret;
});

let intervalId;

function startInterval() {
  intervalId = setInterval(() => {
    now.value = Date.now();
  }, 1000);
}
function stopInterval() {
  if (intervalId) {
    clearInterval(intervalId);
  }
}

watch(datetime, (newVal, oldVal) => {
  if (!oldVal.expired && newVal.expired) {
    stopInterval();
    emit("expireChanged", newVal.expired);
  } else if (oldVal.expired && !newVal.expired) {
    startInterval();
    emit("expireChanged", newVal.expired);
  }
});

onMounted(startInterval);
onBeforeUnmount(stopInterval);
</script>
