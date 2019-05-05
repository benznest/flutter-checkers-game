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
    if (!isBlockAvailable(men.coordinate)) {
      return;
    }

    if (men.player == 2) {
      if (men.isKing) {
        // King case.
      } else {
        checkWalkablePlayer2Left(men.coordinate);
        checkWalkablePlayer2Right(men.coordinate);
      }
    } else if (men.player == 1) {
      if (men.isKing) {
        // King case.
      } else {
        checkWalkablePlayer1Left(men.coordinate);
        checkWalkablePlayer1Right(men.coordinate);
      }
    }
  }

  bool checkWalkable({Coordinate next, Coordinate nextIfKilling}) {
    if (hasMen(next)) {
      if (hasMenEnemy(next)) {
        if (isBlockAvailable(nextIfKilling) && !hasMen(nextIfKilling)) {
          setHighlightWalkable(nextIfKilling);
          getBlockTable(nextIfKilling).victim =
              Killed(isKilled: true, men: getBlockTable(next).men);
          return true;
        }
      }
    } else {
      setHighlightWalkable(next);
      return true;
    }
    return false;
  }

  bool checkWalkablePlayer2Right(Coordinate coor) {
    return checkWalkable(
        next: Coordinate(row: coor.row - 1, col: coor.col + 1),
        nextIfKilling: Coordinate(row: coor.row - 2, col: coor.col + 2));
  }

  bool checkWalkablePlayer2Left(Coordinate coor) {
    return checkWalkable(
        next: Coordinate(row: coor.row - 1, col: coor.col - 1),
        nextIfKilling: Coordinate(row: coor.row - 2, col: coor.col - 2));
  }

  bool checkWalkablePlayer1Right(Coordinate coor) {
    return checkWalkable(
        next: Coordinate(row: coor.row + 1, col: coor.col + 1),
        nextIfKilling: Coordinate(row: coor.row + 2, col: coor.col + 2));
  }

  bool checkWalkablePlayer1Left(Coordinate coor) {
    return checkWalkable(
        next: Coordinate(row: coor.row + 1, col: coor.col - 1),
        nextIfKilling: Coordinate(row: coor.row + 2, col: coor.col - 2));
  }

  setHighlightWalkable(Coordinate coor) {
    if (isBlockAvailable(coor) && !hasMen(coor)) {
      table[coor.row][coor.col].isHighlight = true;
    }
  }

  bool hasMen(Coordinate coor) {
    return table[coor.row][coor.col].men != null;
  }


  bool hasMenEnemy(Coordinate coor) {
    if (hasMen(coor)) {
      return table[coor.row][coor.col].men.player != currentPlayerTurn;
    }
    return false;
  }


  bool isBlockAvailable(Coordinate coor) {
    if(coor == null){
      return false;
    }
    return coor.row >= 0 && coor.row < countRow && coor.col >= 0 && coor.col < countCol;
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

  bool checkKilled(Coordinate coor) {
    Killed killing = getBlockTable(coor).victim;
    if (killing.isKilled) {
      table[killing.men.coordinate.row][killing.men.coordinate.col].men = null;
      return true;
    }
    return false;
  }

  void addMen(Coordinate coor, {int player = 1}) {
    if (!isBlockTypeF(coor)) {
      List<Men> listMen = player == 1 ? listMenPlayer1 : listMenPlayer2;
      Men men = Men(
          player: player, coordinate: Coordinate.copy(coor));
      listMen.add(men);
      getBlockTable(coor).men = men;
    }
  }

  bool isBlockTypeF(Coordinate coor) {
    return (coor.row % 2 == 0 && coor.col % 2 == 0) || (coor.row % 2 == 1 && coor.col % 2 == 1);
  }

  BlockTable getBlockTable(Coordinate coor) {
    return table[coor.row][coor.col];
  }
}