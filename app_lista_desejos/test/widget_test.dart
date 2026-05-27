import 'package:flutter_test/flutter_test.dart';

import 'package:app_lista_desejos/src/app_lista_desejos.dart';

void main() {
  testWidgets('App launches with home page', (WidgetTester tester) async {
    await tester.pumpWidget(const AppListaDesejos());
    expect(find.text('Mural de Desejos'), findsOneWidget);
  });
}
