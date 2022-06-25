import 'package:sparsearray2d/sparsearray2d.dart';

class SparseMatrix<E extends num> {
  SparseMatrix(final int numRows, final int numColumns)
      : sparseArray2D = SparseArray2D<E>(
            _checkNumRows(numRows), _checkNumColumns(numColumns));

  SparseMatrix.from(final SparseMatrix<E> other)
      : sparseArray2D = SparseArray2D<E>.from(other.sparseArray2D);

  SparseMatrix.fromDense(final Iterable<Iterable<E>> denseRows)
      : sparseArray2D =
            SparseArray2D<E>(denseRows.length, denseRows.first.length) {
    final rowLength = sparseArray2D.numDenseColumns;
    int rowIdx = 0;
    for (final denseRow in denseRows) {
      if (denseRow.length != rowLength) {
        throw ArgumentError.value(denseRow, 'denseRows[$rowIdx]',
            'Dense rows must all be same length.');
      }
      sparseArray2D.putAllRow(
          rowIdx, 0, denseRow.map((final e) => e == 0 ? null : e));
      rowIdx++;
    }
  }

  final SparseArray2D<E> sparseArray2D;

  Iterable<E> rowAt(final int rowIdx) =>
      sparseArray2D.denseRowAt(rowIdx).withDefault(0 as E);

  Iterable<E> columnAt(final int columnIdx) =>
      sparseArray2D.denseColumnAt(columnIdx).withDefault(0 as E);

  void put(final int rowIdx, final int columnIdx, final E value) {
    if (value == 0) {
      sparseArray2D.remove(rowIdx, columnIdx);
    } else {
      sparseArray2D.put(rowIdx, columnIdx, value);
    }
  }

  void remove(final int rowIdx, final int columnIdx) =>
      sparseArray2D.remove(rowIdx, columnIdx);

  E elementAt(final int rowIdx, final int columnIdx) =>
      (sparseArray2D.elementAt(rowIdx, columnIdx)?.value) ?? (0 as E);

  Iterable<Iterable<E>> get rows =>
      sparseArray2D.denseRows.map((final e) => e.withDefault(0 as E));

  Iterable<Iterable<E>> get columns =>
      sparseArray2D.denseColumns.map((final e) => e.withDefault(0 as E));

  int get numRows => sparseArray2D.numDenseRows;

  int get numColumns => sparseArray2D.numDenseColumns;

  SparseMatrix<E> transposed() {
    final SparseMatrix<E> result = SparseMatrix<E>(numColumns, numRows);
    for (final element in sparseArray2D.elements) {
      result.put(element.columnIndex, element.rowIndex, element.value);
    }
    return result;
  }

  SparseMatrix<E> scalarAdd(final E scalar) {
    final SparseMatrix<E> result = SparseMatrix<E>(numRows, numColumns);
    for (final element in sparseArray2D.elements) {
      result.put(
          element.rowIndex, element.columnIndex, (element.value + scalar) as E);
    }
    return result;
  }

  SparseMatrix<E> scalarSubtract(final E scalar) {
    final SparseMatrix<E> result = SparseMatrix<E>(numRows, numColumns);
    for (final element in sparseArray2D.elements) {
      result.put(
          element.rowIndex, element.columnIndex, (element.value - scalar) as E);
    }
    return result;
  }

  SparseMatrix<E> scalarMultiply(final E scalar) {
    final SparseMatrix<E> result = SparseMatrix<E>(numRows, numColumns);
    if (scalar == 0) {
      // zero multiplication rule
      return result;
    }
    for (final element in sparseArray2D.elements) {
      result.put(
          element.rowIndex, element.columnIndex, (element.value * scalar) as E);
    }
    return result;
  }

  SparseMatrix<E> scalarDivide(final E scalar) {
    final SparseMatrix<E> result = SparseMatrix<E>(numRows, numColumns);
    if (scalar == 0) {
      throw ArgumentError('Divide by zero');
    }
    for (final element in sparseArray2D.elements) {
      result.put(
          element.rowIndex, element.columnIndex, (element.value / scalar) as E);
    }
    return result;
  }

  SparseMatrix<E> operator +(final SparseMatrix<E> other) {
    _checkOtherSameSize(other);
    final SparseMatrix<E> result = SparseMatrix<E>.from(this);

    Future<void> addFunc(final Element<E>? thisElement,
        final Element<E>? otherElement, final int index) async {
      if (identical(thisElement, null)) {
        result.put(otherElement!.rowIndex, otherElement.columnIndex,
            otherElement.value);
      } else if (identical(otherElement, null)) {
        result.put(
            thisElement.rowIndex, thisElement.columnIndex, thisElement.value);
      } else {
        assert(thisElement.rowIndex == otherElement.rowIndex);
        assert(thisElement.columnIndex == otherElement.columnIndex);
        result.put(thisElement.rowIndex, thisElement.columnIndex,
            (thisElement.value + otherElement.value) as E);
      }
    }

    final thisRows = sparseArray2D.sparseRows.iterator;
    final otherRows = other.sparseArray2D.sparseRows.iterator;

    while (thisRows.moveNext() && otherRows.moveNext()) {
      thisRows.current.foreachCombined(otherRows.current, addFunc);
    }

    return result;
  }

  SparseMatrix<E> operator -(final SparseMatrix<E> other) {
    _checkOtherSameSize(other);
    final SparseMatrix<E> result = SparseMatrix<E>.from(this);

    Future<void> addFunc(final Element<E>? thisElement,
        final Element<E>? otherElement, final int index) async {
      if (identical(thisElement, null)) {
        result.put(otherElement!.rowIndex, otherElement.columnIndex,
            otherElement.value);
      } else if (identical(otherElement, null)) {
        result.put(
            thisElement.rowIndex, thisElement.columnIndex, thisElement.value);
      } else {
        assert(thisElement.rowIndex == otherElement.rowIndex);
        assert(thisElement.columnIndex == otherElement.columnIndex);
        result.put(thisElement.rowIndex, thisElement.columnIndex,
            (thisElement.value - otherElement.value) as E);
      }
    }

    final thisRows = sparseArray2D.sparseRows.iterator;
    final otherRows = other.sparseArray2D.sparseRows.iterator;

    while (thisRows.moveNext() && otherRows.moveNext()) {
      thisRows.current.foreachCombined(otherRows.current, addFunc);
    }

    return result;
  }

  SparseMatrix<E> operator *(final SparseMatrix<E> other) {
    if (other.numRows != numColumns) {
      throw ArgumentError.value(
          other.numRows, 'other.numRows', 'Must be equal to this.numColumns');
    }

    final SparseMatrix<E> result = SparseMatrix<E>(numRows, other.numColumns);

    return result;
  }

  /// Return true if matrix contains all zeros.
  bool get isZeroMatrix => sparseArray2D.isEmpty;

  @override
  String toString() {
    final buff = StringBuffer();
    for (final row in rows) {
      buff.writeln(row);
    }

    return buff.toString();
  }

  void _checkOtherSameSize(final SparseMatrix<E> other) {
    if (sparseArray2D.numDenseColumns != other.sparseArray2D.numDenseColumns ||
        sparseArray2D.numDenseRows != other.sparseArray2D.numDenseRows) {
      throw ArgumentError(
          'Other SparseMatrix size (${other.sparseArray2D.numDenseRows}, ${other.sparseArray2D.numDenseColumns}) is different to this matrix size (${sparseArray2D.numDenseRows}, ${sparseArray2D.numDenseColumns}).');
    }
  }
}

int _checkNumRows(final int numRows) {
  if (numRows <= 0) {
    throw ArgumentError.value(numRows, 'numRow', 'Must be greater than 0');
  }
  return numRows;
}

int _checkNumColumns(final int numColumns) {
  if (numColumns <= 0) {
    throw ArgumentError.value(
        numColumns, 'numColumns', 'Must be greater than 0');
  }
  return numColumns;
}
