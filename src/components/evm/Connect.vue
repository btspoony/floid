<template>
  <div>
    <div v-if="evmAccount" class="flex items-center justify-between rounded-full bg-accent">
      <span class="flex-auto h-4 leading-4 pl-4 pr-1 font-medium">
        {{ evmAddress ?? "No Address" }}
      </span>
      <button class="flex-none btn btn-sm btn-circle btn-accent" @click="logout">
        <LogoutIcon class="fill-current h-4 w-4" />
      </button>
    </div>
    <button v-else :class="['btn btn-sm btn-accent', props.full && 'btn-block']" @click="connectWallet">
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
const evmProvider = useEVMProvider();
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
    const addr = await newVal.getAddress();
    if (typeof addr === "string") {
      const ens = await evmProvider.value?.lookupAddress(addr);
      if (typeof ens === "string") {
        evmAddress.value = ens;
      } else {
        evmAddress.value =
          addr.slice(0, 5) + "..." + addr.slice(addr.length - 5);
      }
    }
  } else {
    evmAddress.value = null;
  }
});

onMounted(() => {
  // nextTick(() => {
  //   if (web3modal.cachedProvider) {
  //     evmProvider.value = web3modal.cachedProvider;
  //     evmAccount.value = evmProvider.value.getSigner();
  //   }
  // });
});

async function connectWallet() {
  console.log(web3modal);
  const instance = await web3modal.connect();
  evmProvider.value = new ethers.providers.Web3Provider(instance);
  evmAccount.value = evmProvider.value.getSigner();
}

function logout() {
  evmAccount.value = null;
}
</script>
