import VueLazyLoad from "vue3-lazyload";
import { Web3ModalVuePlugin } from "web3modal-vue3";

export default defineNuxtPlugin((nuxtApp) => {
  // image lazy load
  nuxtApp.vueApp.use(VueLazyLoad);
  // web3modal
  nuxtApp.vueApp.use(Web3ModalVuePlugin);
});
