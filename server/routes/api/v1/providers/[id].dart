import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String id) {
  return Response.json(body: {
    'success': true,
    'data': {'id': id},
    'message': 'Provider detail endpoint',
  });
}
