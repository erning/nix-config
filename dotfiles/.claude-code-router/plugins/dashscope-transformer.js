class DashScopeTransformer {
  name = "dashscope";

  constructor(options) {
    this.max_tokens = options.max_tokens || 8192;
    this.enable_thinking = options.enable_thinking || false;
    this.stream = options.stream || true;
  }

  async transformRequestIn(request, provider) {
    request.max_tokens = this.max_tokens;
    request.enable_thinking = this.enable_thinking;
    request.stream = this.stream;
    return request;
  }
}

module.exports = DashScopeTransformer;
