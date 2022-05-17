import { defineNuxtConfig } from "nuxt";
import { NodeGlobalsPolyfillPlugin } from "@esbuild-plugins/node-globals-polyfill";

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
  // vite configure
  vite: {
    // raw assets
    assetsInclude: ["**/*.cdc"],
    // Dependency Pre-Bundling
    optimizeDeps: {
      esbuildOptions: {
        define: {
          global: "globalThis",
        },
        plugins: [
          NodeGlobalsPolyfillPlugin({
            buffer: true,
          }),
        ],
      },
    },
  },
});
