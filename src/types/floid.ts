// Decode for ExpirableMessage
export class ExpirableMessage {
  msg: string;
  expireAt: number;

  constructor(raw: { msg: string; expireAt: number }) {
    this.msg = raw.msg;
    this.expireAt = raw.expireAt;
  }
}
