import 'package:flutter_test/flutter_test.dart';
import 'package:balancing_maze/main.dart';
import 'package:balancing_maze/core/services/game_service.dart';

void main() {
  testWidgets('Balancing Maze app initializes and renders', (WidgetTester tester) async {
    final gameService = GameService();
    await tester.pumpWidget(BalancingMazeApp(gameService: gameService));

    // Verify that the title text is rendered on the splash screen
    expect(find.text('BALANCE'), findsOneWidget);
    expect(find.text('RUNNER'), findsOneWidget);
  });
}
