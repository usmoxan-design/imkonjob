import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(body: {
    'app': 'Imkon Job API',
    'version': '1.0.0',
    'status': 'running',
  });
}
