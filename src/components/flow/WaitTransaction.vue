<template>
  <div class="card min-w-40 max-w-full flex flex-col items-center">
    <p class="font-semibold text-lg pb-2">
      Status: <span class="text-secondary">{{ txStatusString }}</span>
    </p>
    <progress class="progress progress-secondary w-40" :value="progress" max="100"></progress>
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

const STATUS_MAP = {
  0: "UNKNOWN",
  1: "PENDING",
  2: "FINALIZED",
  3: "EXECUTED",
  4: "SEALED",
  5: "EXPIRED",
};

const txStatus = ref<TransactionReceipt>(null);

const txStatusString = computed(() => STATUS_MAP[txStatus.value?.status ?? 0]);
const progress = computed(() => {
  const status = txStatus.value?.status ?? 0;
  if (status === 5) {
    return 0;
  }
  return status * 25;
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
