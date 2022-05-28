<template>
  <div :class="[
    'inline-block transition-all duration-500',
    isShowup ? 'translate-y-0 opacity-100' : 'translate-y-2 opacity-0',
  ]">
    <slot />
  </div>
</template>

<script setup>
const emit = defineEmits({
  update: null,
});

const isShowup = ref(true);
watch(isShowup, (newVal, oldVal) => {
  if (newVal === false) {
    setTimeout(() => {
      emit("update");
    }, 500);
  }
});

let intervalId;

onMounted(() => {
  let count = 5;
  intervalId = setInterval(() => {
    let update = false;
    if (isShowup.value) {
      if (count === 0) {
        update = true;
        count = 5;
      } else {
        count--;
      }
    } else {
      update = true;
    }
    if (update) {
      isShowup.value = !isShowup.value;
    }
  }, 500);
});
onBeforeUnmount(() => {
  clearInterval(intervalId);
});
</script>
