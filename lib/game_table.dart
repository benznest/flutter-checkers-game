import 'package:flutter_draughts_checkers_game/block_table.dart';
import 'package:flutter_draughts_checkers_game/coordinate.dart';
import 'package:flutter_draughts_checkers_game/men.dart';

class GameTable {

  int countRow = 8;
  int countCol = 8;
  List<List<BlockTable>> table;

  GameTable({this.countRow = 8, this.countCol = 8}) {
    init();
  }

  init() {
    table = List();
    for (int row = 0; row < countRow; row++) {
      List<BlockTable> listBlockTable = List();
      for (int col = 0; col < countCol; col++) {
        listBlockTable.add(BlockTable(row: 0, col: 0));
      }

      table.add(listBlockTable);
    }
  }

  clearHighlightWalkable() {
    for (int row = 0; row < countRow; row++) {
      for (int col = 0; col < countCol; col++) {
        table[row][col].isHighlight = false;
      }
    }
  }

  highlightWalkable(Men men) {
    int row = men.coordinate.row;
    int col = men.coordinate.col;

    if (!isBlockAvailable(row, col)) {
      return;
    }

    if (men.player == 2) {
      if (men.isKing) {
        // King case.
      } else {
        setHighlightWalkable(row - 1, col - 1);
        setHighlightWalkable(row - 1, col + 1);
      }
    }
  }

  void setHighlightWalkable(int row, int col) {
    if (!hasMen(row, col)) {
      table[row ][col].isHighlight = true;
    }
  }

  bool hasMen(int row, int col) {
    return table[row][col].men != null;
  }

  isBlockAvailable(int row, int col) {
    return row >= 0 && row < countRow && col >= 0 && col < countCol;
  }

  moveMen(Men men, Coordinate newCoordinate) {
    table[ men.coordinate.row][men.coordinate.col].men = null;
    table[ newCoordinate.row][newCoordinate.col].men = men;
    men.walk(newCoordinate);
  }
}