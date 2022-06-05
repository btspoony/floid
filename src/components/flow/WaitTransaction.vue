<template>
  <div class="panel min-w-40 w-full text-center border-2 border-primary">
    <p class="font-semibold pb-2 text-lg">
      <span class="badge badge-lg badge-primary">{{ txStatusString }}</span>
      <a :href="fvsTx(txid)" target="_blank" class="pl-2 link-highlight">{{
          txidDisplay
      }}</a>
    </p>
    <progress class="progress progress-secondary w-full" :value="progress" max="100"></progress>
  </div>
</template>

<script setup lang="ts">
import type { TransactionReceipt } from "@onflow/fcl";

const props = defineProps<{
  txid: string;
}>();

const emit = defineEmits<{
  (e: "updated", tx: TransactionReceipt): void;
  (e: "sealed", tx: TransactionReceipt): void;
  (e: "error", message: string): void;
}>();

const txStatus = ref<TransactionReceipt>(null);

const txStatusString = computed(() => {
  const STATUS_MAP = {
    0: "UNKNOWN",
    1: "PENDING",
    2: "FINALIZED",
    3: "EXECUTED",
    4: "SEALED",
    5: "EXPIRED",
  };
  return (
    txStatus.value?.statusString ?? STATUS_MAP[txStatus.value?.status || 0]
  );
});

const progress = computed(() => {
  const status = txStatus.value?.status ?? 0;
  switch (status) {
    case 0:
    case 1:
    case 5:
      return undefined;
    case 2:
    case 3:
    case 4:
      return Math.min(100, (status - 1) * 33.34);
  }
});

const txidDisplay = computed(() => {
  const str = props.txid;
  return str.slice(0, 6) + "..." + str.slice(str.length - 6);
});

let unsub: any;

async function startSubscribe() {
  const { $fcl } = useNuxtApp();
  try {
    console.info(
      `%cTX[${props.txid}]: ${fvsTx(props.txid)}`,
      "color:purple;font-weight:bold;font-family:monospace;"
    );
    unsub = await $fcl.tx(props.txid).subscribe((tx) => {
      if (!tx.blockId || !tx.status) return;
      txStatus.value = tx;
      if ($fcl.tx.isSealed(tx)) {
        emit("sealed", tx);
        unsub();
        unsub = null;
      } else {
        emit("updated", tx);
      }
    });
  } catch (err) {
    console.error(`TX[${props.txid}]: ${fvsTx(props.txid)}`, err);
    emit("error", err.message);
  }
}

function stopSubscribe() {
  if (typeof unsub === "function") {
    unsub();
  }
}

function fvsTx(txId: string) {
  const config = useRuntimeConfig();
  const env = config.public.network;
  return `https://flow-view-source.com/${env}/tx/${txId}`;
}

onMounted(startSubscribe);
onBeforeUnmount(stopSubscribe);
</script>
