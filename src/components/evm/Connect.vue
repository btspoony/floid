<template>
  <div>
    <button v-if="!evmAccount" :class="['btn btn-sm btn-outline btn-accent', props.full && 'btn-block']"
      @click="connectWallet">
      Connect EVM Wallet
    </button>
    <EvmAddressDisplay />
    <ClientOnly>
      <Teleport to="body">
        <web3-modal ref="web3modal" :theme="isDark ? 'dark' : 'light'" :provider-options="providerOptions"
          cache-provider />
      </Teleport>
    </ClientOnly>
  </div>
</template>

<script setup lang="ts">
import { ethers } from "ethers";
import WalletConnectProvider from "@walletconnect/web3-provider";

interface Props {
  full?: boolean;
}
const props = withDefaults(defineProps<Props>(), {
  full: false,
});

const config = useRuntimeConfig();

const isDark = useSharedDark();
const evmAccount = useEVMAccount();

const web3modal = ref(null);

const providerOptions = reactive({
  walletconnect: {
    package: WalletConnectProvider,
    options: {
      infuraId: config.infuraId,
    },
  },
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
</script>
