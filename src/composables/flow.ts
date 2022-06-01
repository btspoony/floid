// ---- Account status -----

export const useFlowAccount = () =>
  useState<UserSnapshot>("currentAccount", () => ref(null));

// ----- Setup related -----

export const useCurrentSetupStep = () =>
  useState<number>("currentSetupStep", () => ref(0));

export const useCurrentSetupKey = () =>
  useState<string>("currentSetupKey", () => ref(null));
