import 'package:flutter_draughts_checkers_game/men.dart';

class Killed {
  bool isKilled;
  Men men;

  Killed({this.isKilled = false, this.men});

  Killed.none(){
    isKilled = false;
  }
}