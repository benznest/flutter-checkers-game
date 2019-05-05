class Coordinate {
  int row;
  int col;

  Coordinate({this.row = 0, this.col = 0});

  Coordinate.of(Coordinate coor, {int addRow = 0, int addCol = 0}){
    row = coor.row + addRow;
    col = coor.col + addCol;
  }
}