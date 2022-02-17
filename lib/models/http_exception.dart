class HttpException implements Exception {
  //implements abstract class so we cannot directly instantiate
  //will implement all function in the 'Exception' class
  final String message;
  HttpException(this.message);

  //HTTP package only throws error for 'get' and 'post request
  //so for 'patch' or 'delete' request, we have to manually set error handler

  @override
  String toString() {
    //override normal toString to our custom made
    return message;
  }
}
