import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  // TODO: return from database
  return Response.json(body: {
    'success': true,
    'data': [],
    'total': 0,
    'message': 'Use mock data on client until backend is connected',
  });
}
