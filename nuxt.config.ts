import { defineNuxtConfig } from "nuxt";
import svgLoader from "vite-svg-loader";
import { NodeGlobalsPolyfillPlugin } from "@esbuild-plugins/node-globals-polyfill";

// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
  // set source dir
  srcDir: "src/",
  // Environment Variables
  runtimeConfig: {
    // The private keys which are only available within server-side
    // NOTHING
    // Keys within public, will be also exposed to the client-side
    public: {
      network: "",
      accessApi: "",
      walletDiscovery: "",
      hostUrl: "",
    },
  },
  // ts config
  typescript: {
    shim: false,
  },
  build: {
    transpile: ["@heroicons/vue"],
  },
  // installed modules
  modules: [
    // Doc: https://github.com/nuxt-community/tailwindcss-module
    "@nuxtjs/tailwindcss",
  ],
  // vite configure
  vite: {
    // raw assets
    assetsInclude: ["**/*.cdc"],
    // plugins
    plugins: [
      svgLoader({
        defaultImport: "component",
      }),
    ],
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
  nitro: {
    preset: "vercel",
  },
});
