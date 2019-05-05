import 'package:flutter_draughts_checkers_game/killing.dart';
import 'package:flutter_draughts_checkers_game/men.dart';

class BlockTable {
  int row;
  int col;
  Men men;
  bool isHighlight;
  Killed victim = Killed.none();

  BlockTable({this.row = 0, this.col = 0, this.men, this.isHighlight = false});

}