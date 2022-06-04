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

export class AddressID {
  chain: SupportedChains;
  address: string;
  referID?: string;

  constructor(raw: IJsonObject) {
    this.chain = SupportedChains[SupportedChains[Number(raw.chain)]];
    this.address = raw.address as string;
    this.referID = raw.referID as string;
  }
}
