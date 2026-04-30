## 2024-05-18 - Avoid Re-calculating Totals in ListView.builder Iterations
**Learning:** O(n^2) time complexity bugs in `ListView.builder` blocks where collection sums / aggregations run on each build step are common in Flutter charts or statistics views.
**Action:** Always compute list aggregations (like `.reduce(...)`) *before* returning `ListView.builder` or map loops so that it's O(n) instead of O(n^2).
