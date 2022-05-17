import { defineNuxtConfig } from "nuxt";

// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
  // set source dir
  srcDir: "src/",
  // ts config
  typescript: {
    shim: false,
  },
  // Build transpile
  build: {
    transpile: ["@onflow/fcl"],
  },
  // Environment Variables
  runtimeConfig: {},
});
