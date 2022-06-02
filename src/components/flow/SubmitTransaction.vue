<template>
  <div class="flex flex-col">
    <button v-if="!txid" class="btn btn-sm btn-primary btn-block" @click="startTransaction">
      {{ content }}
    </button>
    <FlowWaitTransaction v-else :txid="txid" />
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  content: string;
  method: () => Promise<string>;
}>();

const txid = ref(null);

function startTransaction() {
  // TODO
}
</script>
