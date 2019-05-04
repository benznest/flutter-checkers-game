import 'package:flutter_draughts_checkers_game/coordinate.dart';

class Men {
  int player;
  bool isKing;
  Coordinate coordinate;

  Men({this.player = 1, this.isKing = false, this.coordinate});

  walk(Coordinate newCoordinate){
    coordinate = newCoordinate;
  }
}