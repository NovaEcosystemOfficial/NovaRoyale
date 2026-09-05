export class ClashRoyaleApiError extends Error {
  readonly statusCode: number;
  readonly reason?: string;

  constructor(statusCode: number, message: string, reason?: string) {
    super(message);
    this.name = "ClashRoyaleApiError";
    this.statusCode = statusCode;
    this.reason = reason;
  }
}
