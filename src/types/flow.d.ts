declare module "*.cdc";
declare module "*.cdc?raw";

declare interface Service {
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

declare interface UserSnapshot {
  addr: string | null;
  cid: string | null;
  expiresAt: number | null;
  f_type: string;
  f_vsn: string;
  loggedIn: boolean | null;
  services?: Service[];
}
