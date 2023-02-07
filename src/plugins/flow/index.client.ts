import * as fcl from "@onflow/fcl";
import { send as grpcSend } from "@onflow/transport-grpc";
import * as scripts from "./scripts";
import * as transactions from "./transactions";
import * as floid from "../../types/floid";
import { replaceImportAddresses } from "./utils";

export default defineNuxtPlugin((nuxtApp) => {
  const config = useRuntimeConfig();

  const isMainnet = config.public.network === "mainnet";
  const appName = "Floid";

  const kvMapping = {
    "flow.network": config.public.network,
    "accessNode.api": config.public.accessApi,
    "discovery.wallet": config.public.walletDiscovery,
    "sdk.transport": grpcSend,
    "app.detail.title": appName,
    "app.detail.icon": config.public.hostUrl + "/apple-touch-icon.png",
    "service.OpenID.scopes": "email email_verified name zoneinfo",
    "fcl.limit": 9999,
    "fcl.accountProof.resolver": async () => ({
      appIdentifier: `${appName} App v1.0`,
      // TODO use random hex from server
      nonce: "75f8587e5bd5f9dcc9909d0dae1f0ac5814458b2ae129620502cb936fde7120a",
    }),
  };

  // method of replace imports
  const replaceImports = (code: string) =>
    replaceImportAddresses(
      code,
      // Address mapping
      {
        MetadataViews: isMainnet ? "0x1d7e57aa55817448" : "0x631e88ae7f1d7c20",
        NonFungibleToken: isMainnet
          ? "0x1d7e57aa55817448"
          : "0x631e88ae7f1d7c20",
        FungibleToken: isMainnet ? "0xf233dcee88fe0abe" : "0x9a0766d93b6608b7",
        FlowToken: isMainnet ? "0x1654653399040a61" : "0x7e60df042a9c0868",
        FloidUtils: config.public.floidAddress,
        FloidInterface: config.public.floidAddress,
        FloidProtocol: config.public.floidAddress,
        Floid: config.public.floidAddress,
        FloidAirdrop: config.public.floidAddress,
        AddressBindingStore: config.public.floidAddress,
        KeyValueStore: config.public.floidAddress,
        SocialIDStore: config.public.floidAddress,
      },
      true
    );

  // initialize fcl
  for (const key in kvMapping) {
    const element = kvMapping[key];
    fcl.config().put(key, element);
    if (typeof element === "string") {
      console.log(`[${appName}] Flow config[${key}]: ${element}`);
    }
  }

  // ------ Build scripts ------
  // Page setup - get lastPendingMessage
  async function abstoreGetLastPendingMessage(
    acct: string
  ): Promise<floid.ExpirableMessage | undefined> {
    const res = await fcl.query({
      // FIXME, replace real
      cadence: replaceImports(scripts.mock),
      args: (arg, t) => [arg(acct, t.Address)],
    });
    return res && new floid.ExpirableMessage(res);
  }

  async function abstoreGetBindedAddressIDs(
    acct: string
  ): Promise<Array<floid.AddressID>> {
    const res = await fcl.query({
      // FIXME, replace real
      cadence: replaceImports(scripts.mock),
      args: (arg, t) => [arg(acct, t.Address)],
    });
    if (res && Array.isArray(res)) {
      return Array.prototype.map.call(res, (one: fcl.IJsonObject) => {
        return new floid.AddressID(one);
      });
    } else {
      return [];
    }
  }

  // ------ Build transactions ------

  // Page setup - init and generate
  async function abstoreInitAndGenerateKey(): Promise<string> {
    return await fcl.mutate({
      // FIXME, replace real
      cadence: replaceImports(transactions.mock),
      limit: 9999,
    });
  }

  // Page setup - verify binding message
  async function abstoreVerifyBindingKey(
    address: string,
    message: string,
    publicKey: string,
    signature: string
    // chain: floid.SupportedChains = floid.SupportedChains.EVM
  ): Promise<string> {
    return await fcl.mutate({
      // FIXME, replace real
      cadence: replaceImports(transactions.mock),
      args: (arg, t) => [
        arg(address, t.String),
        arg(message, t.String),
        arg(publicKey, t.String),
        arg(signature, t.String),
      ],
      limit: 9999,
    });
  }

  return {
    provide: {
      appName: () => appName,
      fcl: fcl,
      scripts: { abstoreGetLastPendingMessage, abstoreGetBindedAddressIDs },
      transactions: { abstoreInitAndGenerateKey, abstoreVerifyBindingKey },
    },
  };
});
