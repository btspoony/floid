import * as fcl from "@onflow/fcl";

export default defineNuxtPlugin((nuxtApp) => {
  const config = useRuntimeConfig();
  const appName = "Floid";

  const kvMapping = {
    "flow.network": config.public.network,
    "accessNode.api": config.public.accessApi,
    "discovery.wallet": config.public.walletDiscovery,
    "app.detail.title": appName,
    "app.detail.icon": config.public.hostUrl + "/apple-touch-icon.png",
    "service.OpenID.scopes": "email email_verified name zoneinfo",
    "fcl.accountProof.resolver": async () => ({
      appIdentifier: `${appName} App v1.0`,
      // TODO use random hex from server
      nonce: "75f8587e5bd5f9dcc9909d0dae1f0ac5814458b2ae129620502cb936fde7120a",
    }),
    // "0xFlowToken": "0x7e60df042a9c0868"
  };

  // initialize fcl
  for (const key in kvMapping) {
    const element = kvMapping[key];
    fcl.config().put(key, element);
    if (typeof element === "string") {
      console.log(`[${appName}] Flow config[${key}]: ${element}`);
    }
  }

  return {
    provide: {
      appName: () => appName,
      fcl: fcl,
    },
  };
});
