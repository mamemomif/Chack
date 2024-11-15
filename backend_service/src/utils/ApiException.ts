export class ApiException extends Error {
  public statusCode: number;

  constructor(message: string, statusCode = 500) {
    super(message);
    this.name = "ApiException";
    this.statusCode = statusCode;
  }
}
