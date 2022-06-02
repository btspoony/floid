import type { UserSnapshot } from "@onflow/fcl";
import { ExpirableMessage } from "~/types/floid";

// ---- Account status -----

export const useFlowAccount = () =>
  useState<UserSnapshot>("currentAccount", () => ref(null));

// ----- Setup related -----

export const useCurrentSetupStep = () =>
  useState<number>("currentSetupStep", () => ref(0));

export const useCurrentSetupMessage = () =>
  useState<ExpirableMessage>("currentSetupMessage", () => ref(null));
