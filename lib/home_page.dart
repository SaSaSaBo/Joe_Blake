// ignore_for_file: constant_identifier_names, camel_case_types, prefer_interpolation_to_compose_strings, sort_child_properties_last, avoid_unnecessary_containers

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:joe_blake/blank_pixel.dart';
import 'package:joe_blake/food_pixel.dart';
import 'package:joe_blake/highscore_tile.dart';
import 'package:joe_blake/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGTH }

class _HomePageState extends State<HomePage> {
  /*grid dimensions*/
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  /*game settings */
  bool gameHasStarted = false;
  final _nameController = TextEditingController();

  /*gamer score */
  int currentScore = 0;

  /*snake position */
  List<int> snakePos = [0, 1, 2];

  /*snake directionis initially to the rigth */
  var currentDirection = snake_Direction.RIGTH;

  /*food position */
  int foodPos = 67;

  /*highscores list */
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(5)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }

  /*start the game */
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        /*keep the snake moving */
        moveSnake();

        /*check if game is over */
        if (gameOver()) {
          timer.cancel();

          /*display a message to the gamer */
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('GAME OVER'),
                  content: Column(
                    children: [
                      Text('Your score is: ' + currentScore.toString()),
                      TextField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(hintText: 'Enter Name'),
                      ),
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        submitScore();
                        Navigator.pop(context);
                        newGame();
                      },
                      child: const Text('Submit'),
                      color: const Color.fromARGB(255, 0, 140, 255),
                    )
                  ],
                );
              });
        }
      });
    });
  }

  void submitScore() {
    /*get access the collection */
    var database = FirebaseFirestore.instance;
    database.collection('highscores').add({
      'name': _nameController.text,
      'score': currentScore,
    });

    /*firebase */
  }

  /*start a new game */
  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [0, 1, 2];
      foodPos = 97;
      currentDirection = snake_Direction.RIGTH;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    /*making sure new food is not where the snake is */
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGTH:
        {
          /*if snake is at the rigth wall, need to readjust */
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;

      case snake_Direction.LEFT:
        {
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;

      case snake_Direction.UP:
        {
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;

      case snake_Direction.DOWN:
        {
          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;

      default:
    }
    /*snake is eating food */
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      snakePos.removeAt(0);
    }
  }

  /*game over */
  bool gameOver() {
    /*gae is pver when the snake runs into itself 
    this occurs when there is a duplicate position in the snakePos list
    
    this list is the body of the snake (no head)*/
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);

    if (bodySnake.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    /*get the screen width */
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: screenWidth > 428 ? 428 : screenWidth,
        child: Column(
          children: [
            /*high scores*/
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /*gamer current score */
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Current Score: '),
                        Text(currentScore.toString()),
                      ],
                    ),
                  ),

                  /*highscore, top5 */
                  Expanded(
                    child: gameHasStarted
                        ? Container()
                        : FutureBuilder(
                            future: letsGetDocIds,
                            builder: (context, snapshot) {
                              return ListView.builder(
                                itemCount: highscore_DocIds.length,
                                itemBuilder: ((context, index) {
                                  return HighScoreTile(
                                    documentId: highscore_DocIds[index],
                                  );
                                }),
                              );
                            }),
                  )
                ],
              ),
            ),

            /*game grid*/
            Expanded(
              flex: 6,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0 &&
                      currentDirection != snake_Direction.UP) {
                    currentDirection = snake_Direction.DOWN;
                  } else if (details.delta.dy < 0 &&
                      currentDirection != snake_Direction.DOWN) {
                    currentDirection = snake_Direction.UP;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0 &&
                      currentDirection != snake_Direction.LEFT) {
                    currentDirection = snake_Direction.RIGTH;
                  } else if (details.delta.dx < 0 &&
                      currentDirection != snake_Direction.RIGTH) {
                    currentDirection = snake_Direction.LEFT;
                  }
                },
                child: GridView.builder(
                    itemCount: totalNumberOfSquares,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowSize),
                    itemBuilder: (context, index) {
                      //return const BlankPixel();
                      //return Text(index.toString());
                      if (snakePos.contains(index)) {
                        return const SnakePixel();
                      } else if (foodPos == index) {
                        return const FoodPixel();
                      } else {
                        return const BlankPixel();
                      }
                    }),
              ),
            ),

            /*play button*/
            Expanded(
              child: Container(
                child: Center(
                  child: MaterialButton(
                    child: const Text('PLAY'),
                    color: gameHasStarted
                        ? const Color.fromARGB(118, 158, 158, 158)
                        : const Color.fromARGB(255, 255, 17, 0),
                    onPressed: gameHasStarted ? () {} : startGame,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
