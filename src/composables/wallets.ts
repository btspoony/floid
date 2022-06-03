import type { UserSnapshot } from "@onflow/fcl";
import { Signer, providers } from "ethers";

// ---- Flow status -----

export const useFlowAccount = () =>
  useState<UserSnapshot>("currentFlowAccount", () => ref(null));

// ---- EVM status -----

export const useEVMAccount = () =>
  useState<Signer>("currentEVMAccount", () => ref(null));

export const useEVMProvider = () =>
  useState<providers.JsonRpcProvider>("currentEVMProvider", () => ref(null));
