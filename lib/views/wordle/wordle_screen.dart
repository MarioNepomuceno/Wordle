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
    return AnimatedBuilder(
        animation: wordleController,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'TERMO',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text("Opções"),
                  ),
                  ListTile(
                    leading: const Tooltip(
                      message: "Permitir palavras que não existem.",
                      child: Icon(Icons.help_outline),
                    ),
                    title: const Text("Permitir qualquer palavra"),
                    trailing: Checkbox(
                      value: wordleController.gameOptions.allowAnyWord,
                      onChanged: (value) {
                        wordleController.changeAllowAnyWord();
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Tooltip(
                      message: "Mostrar caracteres especiais. (ã ó ç)",
                      child: Icon(Icons.help_outline),
                    ),
                    title: const Text("Mostra Acentuação"),
                    trailing: Checkbox(
                      value: wordleController.gameOptions.showSpecialCharacters,
                      onChanged: (value) {
                        wordleController.changeShowSpecialCharacters();
                      },
                    ),
                  ),
                ],
              ),
            ),
            body: RawKeyboardListener(
              autofocus: true,
              onKey: wordleController.handleKey,
              focusNode: FocusNode(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
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
                                    .map(
                                      (j, letter) => MapEntry(
                                        j,
                                        FlipCard(
                                          key: wordleController.flipCardKeys[i]
                                              [j],
                                          flipOnTouch: false,
                                          speed: 1000,
                                          direction: FlipDirection.HORIZONTAL,
                                          front: GestureDetector(
                                            onTap: () {
                                              wordleController.onCardTapped(
                                                word,
                                                j,
                                              );
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
                                        ),
                                      ),
                                    )
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
            ),
          );
        });
  }
}
