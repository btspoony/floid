import { defineNuxtConfig } from "nuxt";
import { resolve } from "path";
import svgLoader from "vite-svg-loader";
import nodePolyfills from "rollup-plugin-polyfill-node";
import { NodeGlobalsPolyfillPlugin } from "@esbuild-plugins/node-globals-polyfill";
import { NodeModulesPolyfillPlugin } from "@esbuild-plugins/node-modules-polyfill";

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
    transpile: [
      "@heroicons/vue",
      "@ethersproject",
      "ethers",
      "json-rpc-engine",
    ],
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
      // ↓ Needed for development mode
      !isProduction &&
        nodePolyfills({
          include: [
            "node_modules/**/*.js",
            new RegExp("node_modules/.vite/.*js"),
          ],
        }),
    ],
    optimizeDeps: {
      include: ["bn.js", "js-sha3", "hash.js", "aes-js", "scrypt-js", "bech32"],
      esbuildOptions: {
        // Node.js global to browser globalThis
        define: {
          global: "globalThis",
        },
        // Enable esbuild polyfill plugins
        plugins: [
          NodeGlobalsPolyfillPlugin({
            process: true,
            buffer: true,
          }),
          NodeModulesPolyfillPlugin(),
        ],
      },
    },
    build: {
      rollupOptions: {
        plugins: [
          // ↓ Needed for build
          nodePolyfills(),
        ],
      },
      // ↓ Needed for build if using WalletConnect and other providers
      commonjsOptions: {
        transformMixedEsModules: true,
      },
    },
  },
  nitro: {
    preset: "vercel",
  },
});
