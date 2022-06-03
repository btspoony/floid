import type { UserSnapshot } from "@onflow/fcl";

// ---- Flow status -----

export const useFlowAccount = () =>
  useState<UserSnapshot>("currentFlowAccount", () => ref(null));

// ---- EVM status -----

export const useEvmAccount = () =>
  useState<string>("currentEVMAccount", () => ref(null));
