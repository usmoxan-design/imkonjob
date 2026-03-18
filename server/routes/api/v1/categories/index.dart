import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(body: {
    'success': true,
    'data': [
      {'id': 'plumbing', 'name': 'Santexnik', 'icon': '🔧'},
      {'id': 'electrical', 'name': 'Elektrik', 'icon': '⚡'},
      {'id': 'cleaning', 'name': 'Tozalash', 'icon': '🧹'},
      {'id': 'moving', 'name': "Ko'chirish", 'icon': '🚚'},
      {'id': 'repair', 'name': 'Remont', 'icon': '🏠'},
      {'id': 'ac', 'name': 'Konditsioner', 'icon': '❄️'},
      {'id': 'welding', 'name': 'Payvandchi', 'icon': '🔥'},
      {'id': 'carpentry', 'name': 'Duradgor', 'icon': '🪚'},
    ],
  });
}
