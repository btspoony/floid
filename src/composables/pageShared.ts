import { ExpirableMessage } from "~/types/floid";

// ----- Setup related -----

export const useCurrentSetupStep = () =>
  useState<number>("currentSetupStep", () => ref(0));

export const useCurrentSetupMessage = () =>
  useState<ExpirableMessage>("currentSetupMessage", () => ref(null));
