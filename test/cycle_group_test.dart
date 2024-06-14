import 'package:cycle_group/cycle_group.dart';
import 'package:test/test.dart';

class TestNode {
  TestNode(this.name);

  final String name;
  List<TestNode> children = [];
}

void calculateAndPrint(List<TestNode> nodes, List<TestNode> roots) {
  String joinNodeNames(List<TestNode> nodes) => nodes.map((n) => n.name).join(', ');
  print('Inputs:');
  for (final node in nodes) {
    print('  [${node.name}] -> [${joinNodeNames(node.children)}]');
  }
  final groups = calculateCycleGroups(roots, (node) => node.children);
  print('\nOutputs:');
  for (final group in groups) {
    print('  [${group.index} (${joinNodeNames(group.nodes)})] -> [${group.references.map((g) => g.index).join(', ')}]');
  }
}

void main() {
  test('test diamond', () {
    final root = TestNode('root');
    final a = TestNode('a');
    final b = TestNode('b');
    final c = TestNode('c');
    root.children.addAll([a, b]);
    a.children.add(c);
    b.children.add(c);

    calculateAndPrint([root, a, b, c], [root]);
  });

  test('test self reference', () {
    final root = TestNode('root');
    root.children.add(root);

    calculateAndPrint([root], [root]);
  });

  test('test single cycle', () {
    final root = TestNode('root');

    // a, b, and c are in a cycle
    final a = TestNode('a');
    final b = TestNode('b');
    final c = TestNode('c');
    a.children.add(b);
    b.children.add(c);
    c.children.add(a);

    // d and e are leaves
    final d = TestNode('d');
    final e = TestNode('e');
    b.children.add(d);
    c.children.add(e);

    root.children.add(a);

    calculateAndPrint([root, a, b, c, d, e], [root]);
  });

  test('test figure 8', () {
    final root = TestNode('root');

    // a, b, and c are in a cycle
    final a = TestNode('a');
    final b = TestNode('b');
    final c = TestNode('c');
    a.children.add(b);
    b.children.add(c);
    c.children.add(a);

    // d and e create another loop in the same cycle
    final d = TestNode('d');
    final e = TestNode('e');
    c.children.add(d);
    d.children.add(e);
    e.children.add(b);

    // f and g are leaves
    final f = TestNode('f');
    final g = TestNode('g');
    d.children.add(f);
    b.children.add(g);

    root.children.add(a);

    calculateAndPrint([root, a, b, c, d, e, f, g], [root]);
  });
}
