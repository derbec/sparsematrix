import 'package:sparsematrix/sparsematrix.dart';

void main() {
  final dense = [
    [1, 0, 3],
    [4, 5, 6],
    [7, 8, 9]
  ];

  final dense1 = [
    [-1, 1, 1],
    [1, 1, 1],
    [1, 1, 1]
  ];

  final awesome = SparseMatrix<int>.fromDense(dense);
  final awesome1 = SparseMatrix<int>.fromDense(dense1);

  print(awesome);
  print(awesome1);

  final added = awesome - awesome1;

  print(added);

  print(added.sparseArray2D.sparseRows.first);

  //print(awesome.columns);
  //print(awesome.rows);
}
