import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    final body = await context.request.json() as Map<String, dynamic>;
    final phone = body['phone'] as String?;
    // TODO: real auth logic
    return Response.json(body: {
      'success': true,
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': '1',
        'name': 'Foydalanuvchi',
        'phone': phone ?? '',
      },
    });
  }
  return Response(statusCode: 405);
}
