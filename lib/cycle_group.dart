class CycleGroup<T> {
  CycleGroup(this.index, this.nodes, this.references);

  final List<T> nodes;
  final List<CycleGroup<T>> references;
  final int index;
}

class IncompleteCycleGroup<T> {
  final List<T> nodes = [];
  final List<CycleGroup<T>> references = [];
  final List<T> unresolvedReferences = [];
}

List<CycleGroup<T>> calculateCycleGroups<T>(List<T> rootNodes, List<T> Function(T) getChildren) {
  List<IncompleteCycleGroup<T>> stack = [];
  List<CycleGroup<T>> completeCycleGroups = [];
  Map<T, CycleGroup<T>> completedNodeMap = {};
  Map<T, IncompleteCycleGroup<T>> incompleteNodeMap = {};

  // This is a placeholder empty group that references the rootset
  final rootGroup = IncompleteCycleGroup<T>();
  rootGroup.unresolvedReferences.addAll(rootNodes);
  stack.add(rootGroup);

  while (stack.isNotEmpty) {
    final currentGroup = stack.last;
    if (currentGroup.unresolvedReferences.isEmpty) {
      // If the incomplete group has no nodes, it is the placeholder group that shouldn't be added
      if (currentGroup.nodes.isNotEmpty) {
        final completedCycleGroup = CycleGroup<T>(completeCycleGroups.length, currentGroup.nodes, currentGroup.references);
        for (final node in currentGroup.nodes) {
          incompleteNodeMap.remove(node);
          completedNodeMap[node] = completedCycleGroup;
        }
        completeCycleGroups.add(completedCycleGroup);
      }
      stack.removeLast();
      continue;
    }

    final unresolvedReference = currentGroup.unresolvedReferences.last;
    final completedGroup = completedNodeMap[unresolvedReference];
    if (completedGroup != null) {
      // We've resolved the reference to its complete cycle group.
      currentGroup.references.add(completedGroup);
      currentGroup.unresolvedReferences.removeLast();
      continue;
    }

    final incompleteGroup = incompleteNodeMap[unresolvedReference];
    if (incompleteGroup != null) {
      currentGroup.unresolvedReferences.removeLast();
      
      // We found a cycle. Merge groups until we find the group we're referencing.
      final mergedNodes = <T>[];
      final mergedReferences = <CycleGroup<T>>[];
      final mergedUnresolvedReferences = <T>[];
      while (stack.isNotEmpty) {
        final nextGroup = stack.last;
        if (nextGroup == incompleteGroup) {
          // This is the group we're referencing. Merge everything down into this group.

          // First, mark all the nodes as belonging to the new group in the maps.
          for (final node in mergedNodes) {
            incompleteNodeMap[node] = incompleteGroup;
          }

          incompleteGroup.nodes.addAll(mergedNodes);
          incompleteGroup.references.addAll(mergedReferences);
          incompleteGroup.unresolvedReferences.addAll(mergedUnresolvedReferences);
          break;
        } else {
          mergedNodes.addAll(nextGroup.nodes);
          mergedReferences.addAll(nextGroup.references);
          mergedUnresolvedReferences.addAll(nextGroup.unresolvedReferences);
          stack.removeLast();
        }
      }
      continue;
    }

    // This is a new node we haven't seen. Make a new incomplete group.
    final newIncompleteGroup = IncompleteCycleGroup<T>();
    newIncompleteGroup.nodes.add(unresolvedReference);
    newIncompleteGroup.unresolvedReferences.addAll(getChildren(unresolvedReference));
    incompleteNodeMap[unresolvedReference] = newIncompleteGroup;
    stack.add(newIncompleteGroup);
  }

  return completeCycleGroups;
}