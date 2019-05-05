import 'package:flutter_draughts_checkers_game/coordinate.dart';

class Men {
  int player;
  bool isKing;
  Coordinate coordinate;

  Men({this.player = 1, this.isKing = false, this.coordinate});

  Men.of(Men men,{Coordinate newCoor}){
    player = men.player;
    isKing = men.isKing;
    coordinate = men.coordinate;

    if(newCoor != null){
      coordinate = newCoor;
    }
  }

  upgradeToKing(){
    isKing = true;
  }
}