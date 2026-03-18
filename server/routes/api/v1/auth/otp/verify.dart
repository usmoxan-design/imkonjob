import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    final body = await context.request.json() as Map<String, dynamic>;
    final otp = body['otp'] as String?;
    if (otp == '1234') {
      return Response.json(body: {'success': true, 'verified': true});
    }
    return Response.json(
      statusCode: 400,
      body: {'success': false, 'message': "Noto'g'ri kod"},
    );
  }
  return Response(statusCode: 405);
}
