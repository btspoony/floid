import { defineNuxtConfig } from "nuxt";
import svgLoader from "vite-svg-loader";
import nodePolyfills from "rollup-plugin-polyfill-node";

const isProduction = process.env.NODE_ENV === "production";

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
      floidAddress: "",
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
      // ↓ Needed for development mode
      !isProduction &&
      nodePolyfills({
        include: [
          "node_modules/**/*.js",
          new RegExp("node_modules/.vite/.*js"),
        ],
      }),
    ],
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
