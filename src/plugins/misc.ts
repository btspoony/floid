import { Web3ModalVuePlugin } from "web3modal-vue3";

export default defineNuxtPlugin((nuxtApp) => {
  // web3modal
  nuxtApp.vueApp.use(Web3ModalVuePlugin);
});
