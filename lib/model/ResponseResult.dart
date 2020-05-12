class ResponseResult{
    final String error;
    final String message;
    final String caused;

  ResponseResult(this.error, this.message, this.caused);

  ResponseResult.fromJson(Map<String,dynamic> data):error = data['error'],message=data['message'],caused=data['caused'];

}