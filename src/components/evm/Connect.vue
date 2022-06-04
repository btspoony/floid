<template>
  <div>
    <div v-if="evmAccount" class="flex items-center justify-between rounded-full text-accent border-accent border-2">
      <span class="flex-auto h-4 leading-4 pl-4 pr-1 font-medium text-center">
        {{ evmAddress ?? "No Address" }}
      </span>
      <button class="flex-none btn btn-sm btn-circle btn-ghost" @click="logout">
        <LogoutIcon class="fill-current h-4 w-4" />
      </button>
    </div>
    <button v-else :class="['btn btn-sm btn-outline btn-accent', props.full && 'btn-block']" @click="connectWallet">
      Connect EVM Wallet
    </button>
    <ClientOnly>
      <Teleport to="body">
        <web3-modal ref="web3modal" :theme="theme" :provider-options="providerOptions" cache-provider />
      </Teleport>
    </ClientOnly>
  </div>
</template>

<script setup lang="ts">
import { LogoutIcon } from "@heroicons/vue/solid";
import { ethers } from "ethers";
import WalletConnectProvider from "@walletconnect/web3-provider";

interface Props {
  full?: boolean;
}
const props = withDefaults(defineProps<Props>(), {
  full: false,
});

const config = useRuntimeConfig();

const theme = useTheme();
const evmAccount = useEVMAccount();
const evmAddress = ref<string>(null);

const web3modal = ref(null);

const providerOptions = reactive({
  walletconnect: {
    package: WalletConnectProvider,
    options: {
      infuraId: config.infuraId,
    },
  },
});

watch(evmAccount, async (newVal, oldVal) => {
  if (newVal !== null) {
    const addr = await toRaw(newVal).getAddress();

    if (typeof addr === "string") {
      const addrDisplay =
        addr.slice(0, 8) + "..." + addr.slice(addr.length - 8);
      // display first
      evmAddress.value = addrDisplay;
      // check ens display
      try {
        const ens = await toRaw(newVal).provider?.lookupAddress(addr);
        if (typeof ens === "string") {
          evmAddress.value = ens;
        }
      } catch (err) { }
    }
  } else {
    evmAddress.value = null;
  }
});

onMounted(() => {
  nextTick(async () => {
    const providerName = web3modal.value?.cachedProvider();
    if (providerName) {
      connectWallet();
    }
  });
});

async function connectWallet() {
  if (!web3modal.value) return;

  const instance = await web3modal.value.connect();
  try {
    const provider = new ethers.providers.Web3Provider(instance);
    const signer = provider.getSigner();
    if (provider && signer) {
      console.log("Connected EVM Address:", await signer?.getAddress());
      evmAccount.value = signer;
    }
  } catch (err) {
    console.error(err);
  }
}

function logout() {
  evmAccount.value = null;
}
</script>
