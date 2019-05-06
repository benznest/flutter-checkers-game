import 'package:flutter_draughts_checkers_game/block_table.dart';
import 'package:flutter_draughts_checkers_game/coordinate.dart';
import 'package:flutter_draughts_checkers_game/killing.dart';
import 'package:flutter_draughts_checkers_game/men.dart';

typedef OnWalkableAfterKilling = bool Function(Coordinate newCoor, Killed killed);
typedef OnKingWalkable = void Function(Coordinate newCoor);
typedef OnKingWalkableAfterKilling = void Function(Coordinate newCoor, Killed killed);
typedef OnKingUnWalkable = void Function(Coordinate newCoor);

class GameTable {

  static const int MODE_WALK_NORMAL = 1; // walk to empty or walk to first kill.
  static const int MODE_WALK_AFTER_KILLING = 2; // walk after kill to 2 3 4.. enemy.
  static const int MODE_AFTER_KILLING = 3; // calculation to future that men can walk.

  int countRow = 8;
  int countCol = 8;
  List<List<BlockTable>> table;
  int currentPlayerTurn = 2;

  List<Coordinate> listTempForKingWalkCalculation = List();

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

  void initMenOnTable() {
    initMenOnTableRow(player: 1, row: 0);
    initMenOnTableRow(player: 1, row: 1);
    initMenOnTableRow(player: 2, row: countRow - 2);
    initMenOnTableRow(player: 2, row: countRow - 1);
  }

  void initMenOnTableRow({int player = 1, int row = 0}) {
    for (int col = 0; col < countCol; col++) {
      addMen(Coordinate(row: row, col: col), player: player);
    }
  }

  clearHighlightWalkable() {
    for (int row = 0; row < countRow; row++) {
      for (int col = 0; col < countCol; col++) {
        table[row][col].isHighlight = false;
        table[row][col].isHighlightAfterKilling = false;
        table[row][col].killableMore = false;
        table[row][col].victim = Killed.none();
      }
    }
  }

  highlightWalkable(Men men, {int mode = MODE_WALK_NORMAL}) {
    if (!isBlockAvailable(men.coordinate)) {
      return;
    }

    if (men.player == 2) {
      if (men.isKing) {
        listTempForKingWalkCalculation.clear();
        checkWalkableKing(men, mode);
      } else {
        checkWalkablePlayer2(men, mode: mode);
      }
    } else if (men.player == 1) {
      if (men.isKing) {
        listTempForKingWalkCalculation.clear();
        checkWalkableKing(men, mode);
      } else {
        checkWalkablePlayer1(men, mode: mode);
      }
    }
  }

  bool checkWalkablePlayer1(Men men, {int mode = MODE_WALK_NORMAL}) {
    bool movableLeft = checkWalkablePlayer1Left(
        men.coordinate, mode: mode, onKilling: (newCoor, killed) {
      int newMode = MODE_AFTER_KILLING;
      return checkWalkablePlayer1(
          Men.of(men, newCoor: newCoor), mode: newMode);
    });

    bool movableRight = checkWalkablePlayer1Right(
        men.coordinate, mode: mode, onKilling: (newCoor, killed) {
      int newMode = MODE_AFTER_KILLING;
      return checkWalkablePlayer1(
          Men.of(men, newCoor: newCoor), mode: newMode);
    });

    return movableLeft || movableRight;
  }


  bool checkWalkablePlayer2(Men men, {int mode = MODE_WALK_NORMAL}) {
    bool movableLeft = checkWalkablePlayer2Left(
        men.coordinate, mode: mode, onKilling: (newCoor, killed) {
      int newMode = MODE_AFTER_KILLING;

      return checkWalkablePlayer2(
          Men.of(men, newCoor: newCoor), mode: newMode);
    });

    bool movableRight = checkWalkablePlayer2Right(
        men.coordinate, mode: mode, onKilling: (newCoor, killed) {
      int newMode = MODE_AFTER_KILLING;
      return checkWalkablePlayer2(
          Men.of(men, newCoor: newCoor), mode: newMode);
    });

    return movableLeft || movableRight;
  }

  bool checkWalkable({int mode, Coordinate next, Coordinate nextIfKilling, OnWalkableAfterKilling onKilling}) {
    if (hasMen(next)) {
      if (hasMenEnemy(next)) {
        if (isBlockAvailable(nextIfKilling) && !hasMen(nextIfKilling)) {
          print("x = $mode");
          if (mode == MODE_WALK_NORMAL || mode == MODE_WALK_AFTER_KILLING) {
            setHighlightWalkableAfterKilling(nextIfKilling);
          }

          Killed killed = Killed(isKilled: true, men: getBlockTable(next).men);
          getBlockTable(nextIfKilling).victim = killed;

          if (onKilling != null) {
            bool isKillable = onKilling(nextIfKilling, killed);
            getBlockTable(nextIfKilling).killableMore = isKillable;
          }
          return true;
        }
      }
    } else {
      if (mode == MODE_WALK_NORMAL) {
        setHighlightWalkable(next);
        return true;
      }
    }
    return false;
  }

  bool checkWalkablePlayer2Right(Coordinate coor,
      {int mode, OnWalkableAfterKilling onKilling}) {
    return checkWalkable(
        mode: mode,
        next: Coordinate(row: coor.row - 1, col: coor.col + 1),
        nextIfKilling: Coordinate(row: coor.row - 2, col: coor.col + 2),
        onKilling: onKilling);
  }

  bool checkWalkablePlayer2Left(Coordinate coor,
      {int mode, OnWalkableAfterKilling onKilling}) {
    return checkWalkable(
        mode: mode,
        next: Coordinate(row: coor.row - 1, col: coor.col - 1),
        nextIfKilling: Coordinate(row: coor.row - 2, col: coor.col - 2),
        onKilling: onKilling);
  }

  bool checkWalkablePlayer1Right(Coordinate coor,
      {int mode, OnWalkableAfterKilling onKilling}) {
    return checkWalkable(
        mode: mode,
        next: Coordinate(row: coor.row + 1, col: coor.col + 1),
        nextIfKilling: Coordinate(row: coor.row + 2, col: coor.col + 2),
        onKilling: onKilling);
  }

  bool checkWalkablePlayer1Left(Coordinate coor,
      {int mode, OnWalkableAfterKilling onKilling}) {
    return checkWalkable(
        mode: mode,
        next: Coordinate(row: coor.row + 1, col: coor.col - 1),
        nextIfKilling: Coordinate(row: coor.row + 2, col: coor.col - 2),
        onKilling: onKilling);
  }

  setHighlightWalkable(Coordinate coor) {
    if (isBlockAvailable(coor) && !hasMen(coor)) {
      getBlockTable(coor).isHighlight = true;
    }
  }

  setHighlightWalkableAfterKilling(Coordinate coor) {
    if (isBlockAvailable(coor) && !hasMen(coor)) {
      getBlockTable(coor).isHighlightAfterKilling = true;
    }
  }

  bool hasMen(Coordinate coor) {
    if (isBlockAvailable(coor)) {
      return getBlockTable(coor).men != null;
    }
    return false;
  }

  bool hasMenEnemy(Coordinate coor) {
    if (hasMen(coor)) {
      return getBlockTable(coor).men.player != currentPlayerTurn;
    }
    return false;
  }

  bool isBlockAvailable(Coordinate coor) {
    if (coor == null) {
      return false;
    }
    return coor.row >= 0 && coor.row < countRow && coor.col >= 0 &&
        coor.col < countCol;
  }

  moveMen(Men men, Coordinate newCoordinate) {
    getBlockTable(men.coordinate).men = null;
    getBlockTable(newCoordinate).men = men;
    men.coordinate = newCoordinate;
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
    if (killing != null && killing.isKilled) {
      getBlockTable(killing.men.coordinate).men = null;
      return true;
    }
    return false;
  }

  bool checkKillableMore(Men men, Coordinate coor) {
    if (men.isKing) {
      listTempForKingWalkCalculation.clear();
      return checkWalkableKing(men, MODE_AFTER_KILLING);
    } else {
      return getBlockTable(coor).killableMore;
    }
  }

  void addMen(Coordinate coor, {int player = 1, bool isKing = false}) {
    if (!isBlockTypeF(coor)) {
//      List<Men> listMen = player == 1 ? listMenPlayer1 : listMenPlayer2;
      Men men = Men(
          player: player, coordinate: Coordinate.of(coor), isKing: isKing);
//      listMen.add(men);
      getBlockTable(coor).men = men;
    }
  }

  bool isBlockTypeF(Coordinate coor) {
    return (coor.row % 2 == 0 && coor.col % 2 == 0) ||
        (coor.row % 2 == 1 && coor.col % 2 == 1);
  }

  BlockTable getBlockTable(Coordinate coor) {
    return table[coor.row][coor.col];
  }

  bool isKingArea({int player, Coordinate coor}) {
    if (player == 1) {
      return coor.row == countRow - 1;
    } else {
      return coor.row == 0;
    }
  }

  bool checkWalkableKing(Men men, int mode) {
    Killed killable1 = checkWalkableKingPath(men, mode, addRow: -1, addCol: -1);
    Killed killable2 = checkWalkableKingPath(men, mode, addRow: -1, addCol: 1);
    Killed killable3 = checkWalkableKingPath(men, mode, addRow: 1, addCol: -1);
    Killed killable4 = checkWalkableKingPath(men, mode, addRow: 1, addCol: 1);
    return killable1.isKilled || killable2.isKilled || killable3.isKilled || killable4.isKilled;
  }

  Killed checkWalkableKingPath(Men men, int mode,
      {int addRow = 0, int addCol = 0}) {
    print("checkWalkableKingPath");
    Killed killable = Killed.none();
    int row = men.coordinate.row + addRow;
    int col = men.coordinate.col + addCol;

    if (row < 0 || row > countRow || col < 0 || col > countCol) {
      return killable;
    }

    for (int i = 0; i < countRow; i++) {
      Coordinate currentCoor = Coordinate(row: row, col: col);

      bool isWalked = listTempForKingWalkCalculation.where((coor) {
        return coor.row == row && coor.col == col;
      })
          .toList()
          .isNotEmpty;

      if (isWalked) {
        return killable;
      } else {
        listTempForKingWalkCalculation.add(currentCoor);
        for (Coordinate c in listTempForKingWalkCalculation) {
          print("Temp = (${c.row},${c.col})");
        }
      }

      bool walkable = checkWalkableKingInBlock(mode,
          currentCoor,
          addRow: addRow,
          addCol: addCol,
          onKingWalkable: (newCoor) {
            if (mode == MODE_WALK_NORMAL) {
              setHighlightWalkable(newCoor);
            }
          },
          onKingWalkableAfterKilling: (newCoor, killed) {
            if (isBlockAvailable(newCoor)) {
              killable = killed;
              getBlockTable(newCoor).victim = killed;
              if (mode == MODE_WALK_NORMAL) {
                setHighlightWalkableAfterKilling(newCoor);
              }
              if (mode == MODE_WALK_AFTER_KILLING) {
                setHighlightWalkableAfterKilling(newCoor);
              }

              print("${newCoor.row},${newCoor.col}");
              bool killableMore = checkWalkableKing(Men.of(men, newCoor: newCoor), MODE_AFTER_KILLING);

              print("killableMore = $killableMore");
              getBlockTable(newCoor).killableMore = killableMore;
            }
          },
          onKingUnwalkable: (newCoor) {

          });


      if (!walkable) {
        return killable;
      }


      row += addRow;
      col += addCol;

      if (row < 0 || row > countRow || col < 0 || col > countCol) {
        return killable;
      }
    }
    return killable;
  }

  bool checkWalkableKingInBlock(int mode, Coordinate coor,
      {
        int addRow = 0, int addCol = 0,
        OnKingWalkable onKingWalkable,
        OnKingWalkableAfterKilling onKingWalkableAfterKilling,
        OnKingUnWalkable onKingUnwalkable}) {
    if (!hasMen(coor)) {
      if (mode == MODE_WALK_NORMAL) {
        setHighlightWalkable(coor);
      }

      if (onKingWalkable != null) {
        onKingWalkable(coor);
      }
      return true;
    } else {
      if (hasMenEnemy(coor)) {
        Men enemyKilled = getBlockTable(coor).men;
        Coordinate nextCoorAfterKill = Coordinate.of(
            coor, addRow: addRow, addCol: addCol);
        if (!hasMen(nextCoorAfterKill)) {
          if (onKingWalkableAfterKilling != null) {
            onKingWalkableAfterKilling(
                nextCoorAfterKill, Killed(isKilled: true, men: enemyKilled));
          }
          return false;
        }
      }
    }

    if (onKingUnwalkable != null) {
      onKingUnwalkable(coor);
    }
    return false;
  }
}