import 'package:flutter_test/flutter_test.dart';
import 'package:rentalin/main.dart';

void main() {
  testWidgets('Rentalin App Boot Smoke Test', (WidgetTester tester) async {
    // Bangun aplikasi Rentalin dan picu frame pertama.
    await tester.pumpWidget(const RentalinApp());

    // Verifikasi bahwa teks 'Rentalin' muncul di layar awal (Splash Screen).
    expect(find.text('Rentalin'), findsOneWidget);
  });
}
