import 'package:flutter_draughts_checkers_game/block_table.dart';
import 'package:flutter_draughts_checkers_game/coordinate.dart';
import 'package:flutter_draughts_checkers_game/killing.dart';
import 'package:flutter_draughts_checkers_game/men.dart';

class GameTable {

  int countRow = 8;
  int countCol = 8;
  List<List<BlockTable>> table;
  List<Men> listMenPlayer1 = List();
  List<Men> listMenPlayer2 = List();
  int currentPlayerTurn = 2;

  GameTable({this.countRow = 8, this.countCol = 8}) {
    init();
  }

  init() {
    table = List();
    for (int row = 0; row < countRow; row++) {
      List<BlockTable> listBlockTable = List();
      for (int col = 0; col < countCol; col++) {
        listBlockTable.add(BlockTable(row: row, col: col));
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
        checkWalkablePlayer2Left(row, col);
        checkWalkablePlayer2Right(row, col);
      }
    } else if (men.player == 1) {
      if (men.isKing) {
        // King case.
      } else {
        setHighlightWalkable(row + 1, col - 1);
        setHighlightWalkable(row + 1, col + 1);
      }
    }
  }

  bool checkWalkablePlayer2Left(int row, int col) {
    if (hasMen(row - 1, col - 1)) {
      if (hasMenEnemy(row - 1, col - 1)) {
        if (isBlockAvailable(row - 2, col - 2) && !hasMen(row - 2, col - 2)) {
          setHighlightWalkable(row - 2, col - 2);
          return true;
        }
      }
    } else {
      setHighlightWalkable(row - 1, col - 1);
      return true;
    }
    return false;
  }

  bool checkWalkablePlayer2Right(int row, int col) {
    if (hasMen(row - 1, col + 1)) {
      if (hasMenEnemy(row - 1, col + 1)) {
        if (isBlockAvailable(row - 2, col + 2) && !hasMen(row - 2, col + 2)) {
          setHighlightWalkable(row - 2, col + 2);
          table[row-2][col+2].victim =
              Killed(isKilled: true, men: table[row - 1][col + 1].men);
          return true;
        }
      }
    } else {
      setHighlightWalkable(row - 1, col + 1);
      return true;
    }
    return false;
  }

  setHighlightWalkable(int row, int col) {
    if (isBlockAvailable(row, col) && !hasMen(row, col)) {
      table[row ][col].isHighlight = true;
    }
  }

  bool hasMen(int row, int col) {
    return table[row][col].men != null;
  }


  bool hasMenEnemy(int row, int col) {
    if (hasMen(row, col)) {
      return table[row][col].men.player != currentPlayerTurn;
    }
    return false;
  }


  bool isBlockAvailable(int row, int col) {
    return row >= 0 && row < countRow && col >= 0 && col < countCol;
  }

  moveMen(Men men, Coordinate newCoordinate) {
    table[ men.coordinate.row][men.coordinate.col].men = null;
    table[ newCoordinate.row][newCoordinate.col].men = men;
    men.walk(newCoordinate);
  }

  togglePlayerTurn() {
    if (currentPlayerTurn == 1) {
      currentPlayerTurn = 2;
    } else {
      currentPlayerTurn = 1;
    }
  }

  bool checkKilled(int row, int col) {
    Killed killing = table[row][col].victim;
    if (killing.isKilled) {
      table[killing.men.coordinate.row][killing.men.coordinate.col].men = null;
      return true;
    }
    return false;
  }
}