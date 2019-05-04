import 'package:flutter/material.dart';
import 'package:flutter_draughts_checkers_game/block_table.dart';
import 'package:flutter_draughts_checkers_game/coordinate.dart';
import 'package:flutter_draughts_checkers_game/game_table.dart';
import 'package:flutter_draughts_checkers_game/men.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkers Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyGamePage(title: 'Checkers Game'),
    );
  }
}

class MyGamePage extends StatefulWidget {

  final Color colorBackgroundF = Color(0xffeec295);
  final Color colorBackgroundT = Color(0xff9a6851);
  final Color colorBorderTable = Color(0xff6d3935);
  final Color colorBackgroundHighlight = Colors.blue[500];

  MyGamePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyGamePageState createState() => _MyGamePageState();
}

class _MyGamePageState extends State<MyGamePage> {

  GameTable gameTable;

  @override
  void initState() {
    gameTable = GameTable(countRow: 8, countCol: 8);
    initMenOnTable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: Center(
          child: buildGameTable(),
        )
    );
  }

  buildGameTable() {
    List<Widget> listCol = List();
    for (int row = 0; row < gameTable.countRow; row++) {
      List<Widget> listRow = List();
      for (int col = 0; col < gameTable.countCol; col++) {
        listRow.add(buildBlockContainer(row, col));
      }

      listCol.add(Row(mainAxisSize: MainAxisSize.min,
          children: listRow));
    }

    return Container(padding: EdgeInsets.all(8),
        color: widget.colorBorderTable,
        child: Column(mainAxisSize: MainAxisSize.min,
            children: listCol));
  }

  Widget buildBlockContainer(int row, int col) {
    BlockTable block = gameTable.table[row][col];

    Color colorBackground;
    if (block.isHighlight) {
      colorBackground = widget.colorBackgroundHighlight;
    } else {
      if (isBlockTypeF(row, col)) {
        colorBackground = widget.colorBackgroundF;
      } else {
        colorBackground = widget.colorBackgroundT;
      }
    }

    Widget menWidget;
    if (block.men != null) {
      Men men = gameTable.table[row][col].men;
      menWidget = Center(child: Container(width: 32, height: 32,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: men.player == 1 ? Colors.black54 : Colors.grey[100])));

      if (men.player == gameTable.currentPlayerTurn) {
        menWidget = Draggable<Men>(
            child: menWidget,
            feedback: menWidget,
            childWhenDragging: Container(),
            data: men,
            onDragStarted: () {
              setState(() {
                gameTable.highlightWalkable(men);
              });
            },
            onDragEnd: (details) {
              setState(() {
                gameTable.clearHighlightWalkable();
              });
            });
      }
    } else {
      menWidget = Container();
    }

    if (!gameTable.hasMen(row, col) && !isBlockTypeF(row, col)) {
      return DragTarget<Men>(
          builder: (context, candidateData, rejectedData) {
//            print("DragTarget builder $row $col");
            return buildBlockTableContainer(colorBackground, menWidget);
          },
          onWillAccept: (men) {
            print("onWillAccept = ${gameTable.table[row][col].isHighlight}");
            return gameTable.table[row][col].isHighlight;
          },
          onAccept: (men) {
            print("onAccept");
            setState(() {
              gameTable.moveMen(men, Coordinate(row: row, col: col));
              gameTable.checkKilled(row, col);
              gameTable.togglePlayerTurn();
            });
          });
    }

    return buildBlockTableContainer(colorBackground, menWidget);
  }

  Widget buildBlockTableContainer(Color colorBackground, Widget menWidget) {
    Widget containerBackground = Container(
        width: 42,
        height: 42,
        color: colorBackground,
        margin: EdgeInsets.all(2),
        child: menWidget);
    return containerBackground;
  }

  bool isBlockTypeF(int row, int col) {
    return (row % 2 == 0 && col % 2 == 0) || (row % 2 == 1 && col % 2 == 1);
  }

  void initMenOnTable() {
    initMenOnTableRow(player: 1, row: 0);
    initMenOnTableRow(player: 1, row: 1);
    initMenOnTableRow(player: 2, row: gameTable.countRow - 2);
    initMenOnTableRow(player: 2, row: gameTable.countRow - 1);
  }

  void initMenOnTableRow({int player = 1, int row = 0}) {
    for (int col = 0; col < gameTable.countCol; col++) {
      if (!isBlockTypeF(row, col)) {
        List<Men> listMen = player == 1 ? gameTable.listMenPlayer1 : gameTable
            .listMenPlayer2;
        Men men = Men(
            player: player, coordinate: Coordinate(row: row, col: col));
        listMen.add(men);
        gameTable.table[row][col].men = men;
      }
    }
  }

}
