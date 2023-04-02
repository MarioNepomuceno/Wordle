import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import '../../controllers/wordle_controller.dart';
import '../../models/enum/letter_status.dart';
import '../../models/letter_model.dart';
import '../../components/shaking.dart';
import 'components/board_tile.dart';
import 'components/keyboard.dart';

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> implements WordleListener {
  final WordleController wordleController = WordleController();

  @override
  void showSnackBar(Color color, String titleText, String buttonText) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.none,
        duration: const Duration(days: 1),
        backgroundColor: color,
        content: Text(
          titleText,
          style: const TextStyle(color: Colors.white),
        ),
        action: SnackBarAction(
          onPressed: wordleController.restart,
          textColor: Colors.white,
          label: buttonText,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    wordleController.setListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Termo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
      body: AnimatedBuilder(
          animation: wordleController,
          builder: (context, snapshot) {
            return RawKeyboardListener(
              autofocus: true,
              onKey: wordleController.handleKey,
              focusNode: FocusNode(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShakeWidget(
                    key: wordleController.shakeKey,
                    shakeCount: 3,
                    shakeOffset: 10,
                    shakeDuration: const Duration(milliseconds: 400),
                    child: Column(
                      children: wordleController.board
                          .asMap()
                          .map(
                            (i, word) => MapEntry(
                              i,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: word.letters
                                    .asMap()
                                    .map((j, letter) => MapEntry(
                                        j,
                                        FlipCard(
                                          key: wordleController.flipCardKeys[i]
                                              [j],
                                          flipOnTouch: false,
                                          speed: 1000,
                                          direction: FlipDirection.HORIZONTAL,
                                          front: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                word.changeLetter(j);
                                              });
                                            },
                                            child: BoardTile(
                                              letter: Letter(
                                                val: letter.val,
                                                status: LetterStatus.initial,
                                              ),
                                              isSelected: word.currentIndex ==
                                                      j &&
                                                  wordleController
                                                          .currentWordIndex ==
                                                      i,
                                            ),
                                          ),
                                          back: BoardTile(
                                            letter: letter,
                                            isSelected: false,
                                          ),
                                        )))
                                    .values
                                    .toList(),
                              ),
                            ),
                          )
                          .values
                          .toList(),
                    ),
                  ),
                  Keyboard(
                    onKeyTapped: wordleController.onKeyTapped,
                    onEnterTapped: wordleController.onEnterTapped,
                    onDeleteTapped: wordleController.onDeleteTapped,
                    letters: wordleController.keyboardLetters,
                  ),
                ],
              ),
            );
          }),
    );
  }
}
