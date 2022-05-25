export interface Service {
  authn?: string;
  f_type: string;
  f_vsn: string;
  id?: string;
  identity?: Record<string, string>;
  provider?: Record<string, string>;
  scoped?: Record<string, string>;
  type: string;
  uid: string;
}

export interface UserSnapshot {
  addr: string | null;
  cid: string | null;
  expiresAt: number | null;
  f_type: string;
  f_vsn: string;
  loggedIn: boolean | null;
  services?: Service[];
}

export const useFlowAccount = () =>
  useState<UserSnapshot>("currentAccount", () => ref(null));
