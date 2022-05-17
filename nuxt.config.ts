import { defineNuxtConfig } from "nuxt";

// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
  // change source dir to web/
  srcDir: "web/",
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
