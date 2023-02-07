import { defineNuxtConfig } from "nuxt";
import { resolve } from "path";
import svgLoader from "vite-svg-loader";
import inject from "@rollup/plugin-inject";
import { nodePolyfills } from "vite-plugin-node-polyfills";

const isProduction = process.env.NODE_ENV === "production";

// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
  // set source dir
  srcDir: "src/",
  // Environment Variables
  runtimeConfig: {
    // The private keys which are only available within server-side
    infuraId: "",
    // Keys within public, will be also exposed to the client-side
    public: {
      network: "",
      accessApi: "",
      walletDiscovery: "",
      hostUrl: "",
      floidAddress: "",
      avatarUrl: "",
      gaId: "",
    },
  },
  // ts config
  typescript: {
    shim: false,
  },
  // installed modules
  modules: [
    // Doc: https://github.com/nuxt-community/tailwindcss-module
    "@nuxtjs/tailwindcss",
  ],
  hooks: {
    // for build mode
    "vite:extendConfig"(clientConfig, { isClient }) {
      if (isClient && process.env.NODE_ENV === "production") {
        clientConfig.resolve.alias["@walletconnect/web3-provider"] = resolve(
          __dirname,
          "./node_modules/@walletconnect/web3-provider/dist/umd/index.min.js"
        );
      }
    },
  },
  build: {
    transpile: ["@heroicons/vue", "@ethersproject", "ethers"],
  },
  // vite configure
  vite: {
    // raw assets
    assetsInclude: ["**/*.cdc"],
    // plugins
    plugins: [
      svgLoader({
        defaultImport: "component",
      }),
      nodePolyfills({
        // Whether to polyfill `node:` protocol imports.
        protocolImports: true,
      }),
    ],
    build: {
      rollupOptions: {
        plugins: [inject({ Buffer: ["buffer", "Buffer"] })],
      },
      // ↓ Needed for build if using WalletConnect and other providers
      commonjsOptions: {
        transformMixedEsModules: true,
      },
    },
    optimizeDeps: {
      include: ["bn.js", "js-sha3", "hash.js", "aes-js", "scrypt-js", "bech32"],
      esbuildOptions: {
        // Node.js global to browser globalThis
        define: {
          global: "globalThis",
        },
      },
    },
  },
  nitro: {
    preset: "vercel",
  },
});
