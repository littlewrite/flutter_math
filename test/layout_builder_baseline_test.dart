import 'package:flutter/material.dart';
import 'package:flutter_math_fork/src/render/layout/layout_builder_baseline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LayoutBuilderPreserveBaseline', () {
    testWidgets('rebuilds with the incoming layout constraints',
        (tester) async {
      final seenMaxWidths = <double>[];

      Widget buildHost(double width) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: width,
              child: LayoutBuilderPreserveBaseline(
                builder: (context, constraints) {
                  seenMaxWidths.add(constraints.maxWidth);
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: 12,
                  );
                },
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildHost(120));
      await tester.pumpWidget(buildHost(180));

      expect(seenMaxWidths, containsAllInOrder([120.0, 180.0]));
      expect(tester.getSize(find.byType(LayoutBuilderPreserveBaseline)),
          const Size(180, 12));
    });

    testWidgets('preserves the child baseline', (tester) async {
      final directTextKey = GlobalKey();
      final wrappedTextKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const SizedBox(width: 8),
                  Text(
                    'baseline',
                    key: directTextKey,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 200,
                    child: LayoutBuilderPreserveBaseline(
                      builder: (context, constraints) => Text(
                        'baseline',
                        key: wrappedTextKey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getTopLeft(find.byKey(directTextKey)).dy,
        tester.getTopLeft(find.byKey(wrappedTextKey)).dy,
      );
    });
  });
}
