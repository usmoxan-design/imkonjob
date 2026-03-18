import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return Response.json(body: {
      'success': true,
      'data': [],
      'message': 'Posts list',
    });
  }
  if (context.request.method == HttpMethod.post) {
    final body = await context.request.json() as Map<String, dynamic>;
    return Response.json(statusCode: 201, body: {
      'success': true,
      'data': {
        'id': 'post_${DateTime.now().millisecondsSinceEpoch}',
        ...body,
      },
    });
  }
  return Response(statusCode: 405);
}
