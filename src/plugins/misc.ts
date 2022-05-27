import VueLazyLoad from "vue3-lazyload";

export default defineNuxtPlugin((nuxtApp) => {
  // image lazy load
  nuxtApp.vueApp.use(VueLazyLoad);
});
