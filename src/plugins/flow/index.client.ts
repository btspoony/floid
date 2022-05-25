import * as fcl from "@onflow/fcl";

export default defineNuxtPlugin((nuxtApp) => {
  const appName = "Floid";
  // initialize fcl
  fcl
    .config()
    .put("flow.network", process.env.CHAIN_ENV)
    .put("accessNode.api", process.env.ACCESS_API)
    .put("discovery.wallet", process.env.WALLET_DISCOVERY)
    .put("app.detail.title", "Floid")
    .put("app.detail.icon", process.env.WEBSITE_BASE + "/apple-touch-icon.png")
    .put("service.OpenID.scopes", "email email_verified name zoneinfo")
    .put("fcl.accountProof.resolver", async () => ({
      appIdentifier: `${appName} App v1.0`,
      // TODO use random hex from server
      nonce: "75f8587e5bd5f9dcc9909d0dae1f0ac5814458b2ae129620502cb936fde7120a",
    }));
  // // .put("0xFlowToken", "0x7e60df042a9c0868")

  return {
    provide: {
      fclAppTitle: () => appName,
      // fcl: () => fcl
    },
  };
});
