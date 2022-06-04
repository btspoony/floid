<template>
  <div v-if="evmAccount" class="flex items-center justify-between rounded-full text-accent border-accent border-2">
    <span class="flex-auto h-4 leading-4 pl-4 pr-1 font-medium text-center">
      {{ evmAddress ?? "No Address" }}
    </span>
    <button v-if="!locked" class="flex-none btn btn-sm btn-circle btn-ghost" @click="logout">
      <LogoutIcon class="fill-current h-4 w-4" />
    </button>
    <div v-else class="h-8"></div>
  </div>
</template>

<script setup lang="ts">
import { LogoutIcon } from "@heroicons/vue/solid";

const props = withDefaults(
  defineProps<{
    locked?: boolean;
  }>(),
  {
    locked: false,
  }
);

const emit = defineEmits<{
  (e: "logout");
}>();

const evmAccount = useEVMAccount();
const evmAddress = ref<string>(null);

watchEffect(
  async () => {
    if (evmAccount.value !== null) {
      const signer = toRaw(evmAccount.value);
      const addr = await signer.getAddress();

      if (typeof addr === "string") {
        const addrDisplay =
          addr.slice(0, 8) + "..." + addr.slice(addr.length - 8);
        // display first
        evmAddress.value = addrDisplay;
        // check ens display
        try {
          const ens = await signer.provider?.lookupAddress(addr);
          if (typeof ens === "string") {
            evmAddress.value = ens;
          }
        } catch (err) { }
      }
    } else {
      evmAddress.value = null;
    }
  },
  { flush: "post" }
);

function logout() {
  emit("logout");
  evmAccount.value = null;
}
</script>
