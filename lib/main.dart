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
  final Color colorAppBar = Color(0xff6d3935);
  final Color colorBackgroundGame = Color(0xffc16c34);
  final Color colorBackgroundHighlight = Colors.blue[500];
  final Color colorBackgroundHighlightAfterKilling = Colors.purple[500];

  MyGamePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyGamePageState createState() => _MyGamePageState();
}

class _MyGamePageState extends State<MyGamePage> {

  GameTable gameTable;
  int modeWalking;

  @override
  void initState() {
    initGame();

    // For test
    gameTable.currentPlayerTurn = 1;
    gameTable.addMen(Coordinate(row: 6, col: 3), player: 1);
    gameTable.addMen(Coordinate(row: 3, col: 4), player: 1, isKing: true);
    gameTable.addMen(Coordinate(row: 6, col: 7), player: 2);
    gameTable.addMen(Coordinate(row: 3, col: 6), player: 2, isKing: true);

    super.initState();
  }

  void initGame() {
    modeWalking = GameTable.MODE_WALK_NORMAL;

    gameTable = GameTable(countRow: 8, countCol: 8);
    gameTable.initMenOnTable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: widget.colorAppBar,
          centerTitle: true,
          title: Text(widget.title.toUpperCase()),
          elevation: 0,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.refresh), onPressed: () {
              setState(() {
                initGame();
              });
            })
          ],
        ),
        body: Container(color: widget.colorBackgroundGame, child:
        Column(children: <Widget>[

          Expanded(
              child: Center(
                child: buildGameTable(),
              )),
          Container(decoration: BoxDecoration(color: widget.colorAppBar,
              boxShadow: [BoxShadow(
                  color: Colors.black26, offset: Offset(0, 3), blurRadius: 12)
              ]),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[buildCurrentPlayerTurn()],),
          ),
        ]))
    );
  }

  buildGameTable() {
    List<Widget> listCol = List();
    for (int row = 0; row < gameTable.countRow; row++) {
      List<Widget> listRow = List();
      for (int col = 0; col < gameTable.countCol; col++) {
        listRow.add(buildBlockContainer(Coordinate(row: row, col: col)));
      }

      listCol.add(Row(mainAxisSize: MainAxisSize.min,
          children: listRow));
    }

    return Container(padding: EdgeInsets.all(8),
        color: widget.colorBorderTable,
        child: Column(mainAxisSize: MainAxisSize.min,
            children: listCol));
  }

  Widget buildBlockContainer(Coordinate coor) {
    BlockTable block = gameTable.getBlockTable(coor);

    Color colorBackground;
    if (block.isHighlight) {
      colorBackground = widget.colorBackgroundHighlight;
    } else if (block.isHighlightAfterKilling) {
      colorBackground = widget.colorBackgroundHighlightAfterKilling;
    } else {
      if (gameTable.isBlockTypeF(coor)) {
        colorBackground = widget.colorBackgroundF;
      } else {
        colorBackground = widget.colorBackgroundT;
      }
    }

    Widget menWidget;
    if (block.men != null) {
      Men men = gameTable
          .getBlockTable(coor)
          .men;

      menWidget =
          Center(child: buildMenWidget(player: men.player, isKing: men.isKing));

      if (men.player == gameTable.currentPlayerTurn) {
        menWidget = Draggable<Men>(
            child: menWidget,
            feedback: menWidget,
            childWhenDragging: Container(),
            data: men,
            onDragStarted: () {
              setState(() {
                print("walking mode = ${modeWalking}");
                gameTable.highlightWalkable(men, mode: modeWalking);
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

    if (!gameTable.hasMen(coor) && !gameTable.isBlockTypeF(coor)) {
      return DragTarget<Men>(
          builder: (context, candidateData, rejectedData) {
//            print("DragTarget builder $row $col");
            return buildBlockTableContainer(colorBackground, menWidget);
          },
          onWillAccept: (men) {
            BlockTable blockTable = gameTable
                .getBlockTable(coor);
            return
              blockTable.isHighlight || blockTable.isHighlightAfterKilling;
          },
          onAccept: (men) {
            print("onAccept");
            setState(() {
              gameTable.moveMen(men, Coordinate.of(coor));
              gameTable.checkKilled(coor);
              if (gameTable.checkKillableMore(coor)) {
                modeWalking = GameTable.MODE_WALK_AFTER_KILLING;
              } else {
                if (gameTable.isKingArea(
                    player: gameTable.currentPlayerTurn, coor: coor)) {
                  men.upgradeToKing();
                }
                modeWalking = GameTable.MODE_WALK_NORMAL;
                gameTable.clearHighlightWalkable();
                gameTable.togglePlayerTurn();
              }
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

  Widget buildCurrentPlayerTurn() {
    return Padding(padding: EdgeInsets.all(12),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text("Current turn".toUpperCase(),
              style: TextStyle(fontSize: 16, color: Colors.white)),
          Padding(padding: EdgeInsets.all(6),
              child: buildMenWidget(player: gameTable.currentPlayerTurn))
        ]));
  }

  buildMenWidget({int player = 1, bool isKing = false, double size = 32}) {
    if (isKing) {
      return Container(width: size, height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: Colors.black45, offset: Offset(0, 4), blurRadius: 4)
              ],
              color: player == 1 ? Colors.black54 : Colors.grey[100]),
          child: Icon(Icons.star,
            color: player == 1 ? Colors.grey[100].withOpacity(0.5) : Colors
                .black54.withOpacity(0.5),
            size: 20,));
    }

    return Container(width: size, height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
                color: Colors.black45, offset: Offset(0, 4), blurRadius: 4)
            ],
            color: player == 1 ? Colors.black54 : Colors.grey[100]));
  }


}
