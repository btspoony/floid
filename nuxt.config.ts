import { defineNuxtConfig } from "nuxt3";

// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
  srcDir: "web/",
  typescript: {
    shim: false,
  },
  build: {
    transpile: ["@onflow/fcl"],
  },
});
