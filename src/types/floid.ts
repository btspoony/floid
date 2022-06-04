import type { IJsonObject } from "@onflow/fcl";

// Decode for ExpirableMessage
export class ExpirableMessage {
  msg: string;
  expireAt: number;

  constructor(raw: IJsonObject) {
    this.msg = raw.msg as string;
    this.expireAt = raw.expireAt as number;
  }
}

export enum SupportedChains {
  EVM,
}
