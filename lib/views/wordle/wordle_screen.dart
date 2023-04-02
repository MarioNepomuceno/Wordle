import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/wordle_controller.dart';
import '../../data/words.dart';
import '../../helpers/string_helper.dart';
import '../../helpers/colors_helper.dart';
import '../../models/enum/game_status.dart';
import '../../models/enum/letter_status.dart';
import '../../models/letter_model.dart';
import '../../models/word_model.dart';
import '../../components/shaking.dart';
import 'components/board_tile.dart';
import 'components/keyboard.dart';

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  final WordleController _wordleController = WordleController();

  final _shakeKey = GlobalKey<ShakeWidgetState>();
  final focusNode = FocusNode();

  int _currentWordIndex = 0;
  GameStatus _gameStatus = GameStatus.playing;

  Word? get _currentWord =>
      _currentWordIndex < _board.length ? _board[_currentWordIndex] : null;

  Word _solution = Word.fromString(
    fiveLetterWords[Random().nextInt(fiveLetterWords.length)].toUpperCase(),
  );

  final List<Word> _board = List.generate(
    6,
    (_) => Word(
      letters: List.generate(
        5,
        (_) => Letter.empty(),
      ),
    ),
  );

  final List<List<GlobalKey<FlipCardState>>> _flipCardKeys = List.generate(
    6,
    (_) => List.generate(
      5,
      (_) => GlobalKey<FlipCardState>(),
    ),
  );

  final Set<Letter> _keyboardLetters = {};

  void _onKeyTapped(String val) {
    if (_gameStatus == GameStatus.playing) {
      setState(() {
        _currentWord?.addLetter(val);
      });
    }
  }

  void _onDeleteTapped() {
    if (_gameStatus == GameStatus.playing) {
      setState(() {
        _currentWord?.removeLetter();
      });
    }
  }

  Future<void> _onEnterTapped() async {
    String exists = fiveLetterWords.firstWhere(
        (element) =>
            element.removeSpecials() ==
            _currentWord!.wordString.removeSpecials(),
        orElse: () => "");

    if (exists != "") {
      if (_gameStatus == GameStatus.playing &&
          _currentWord != null &&
          !_currentWord!.letters.contains(Letter.empty())) {
        _gameStatus = GameStatus.submitting;

        for (var i = 0; i < _currentWord!.letters.length; i++) {
          final currentWordLetter = _currentWord!.letters[i];
          final currentSolutionLetter = _solution.letters[i];

          setState(() {
            if (currentWordLetter.val.removeSpecials() ==
                currentSolutionLetter.val.removeSpecials()) {
              _currentWord!.letters[i] = currentWordLetter.copyWith(
                val: currentSolutionLetter.val,
                status: LetterStatus.correct,
              );
            } else if (_solution.letters.contains(currentWordLetter)) {
              if (_solution.letters
                      .where((element) => element.val == currentWordLetter.val)
                      .length ==
                  _currentWord!.letters
                      .where((element) =>
                          element.val == currentWordLetter.val &&
                          element.status == LetterStatus.correct)
                      .length) {
                _currentWord!.letters[i] =
                    currentWordLetter.copyWith(status: LetterStatus.notInWord);
              } else {
                _currentWord!.letters[i] =
                    currentWordLetter.copyWith(status: LetterStatus.inWord);
              }
            } else {
              _currentWord!.letters[i] =
                  currentWordLetter.copyWith(status: LetterStatus.notInWord);
            }
          });

          final letter = _keyboardLetters.firstWhere(
              (e) => e.val == currentWordLetter.val,
              orElse: () => Letter.empty());
          if (letter.status != LetterStatus.correct) {
            _keyboardLetters.removeWhere((e) => e.val == currentWordLetter.val);
            _keyboardLetters.add(_currentWord!.letters[i]);
          }

          await Future.delayed(
            Duration(milliseconds: i * 150),
            () =>
                _flipCardKeys[_currentWordIndex][i].currentState?.toggleCard(),
          );
        }

        _checkIfWinOrLoss();
      }
    } else {
      _shakeKey.currentState?.shake();
    }
  }

  void _checkIfWinOrLoss() {
    if (_currentWord!.wordString == _solution.wordString) {
      _gameStatus = GameStatus.won;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.none,
          duration: const Duration(days: 1),
          backgroundColor: correctColor,
          content: const Text(
            'Você ganhou!',
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            onPressed: _restart,
            textColor: Colors.white,
            label: 'Novo Jogo',
          ),
        ),
      );
    } else if (_currentWordIndex + 1 >= _board.length) {
      _gameStatus = GameStatus.lost;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.none,
          duration: const Duration(days: 1),
          backgroundColor: Colors.redAccent[200],
          content: Text(
            'Você perdeu! Solução: ${_solution.wordString}',
            style: const TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            onPressed: _restart,
            textColor: Colors.white,
            label: 'Novo Jogo',
          ),
        ),
      );
    } else {
      _gameStatus = GameStatus.playing;
    }

    setState(() {
      _currentWordIndex += 1;
    });
  }

  void _restart() {
    setState(() {
      _gameStatus = GameStatus.playing;
      _currentWordIndex = 0;
      _board
        ..clear()
        ..addAll(
          List.generate(
              6, (_) => Word(letters: List.generate(5, (_) => Letter.empty()))),
        );
      _solution = Word.fromString(
        fiveLetterWords[Random().nextInt(fiveLetterWords.length)].toUpperCase(),
      );
      _keyboardLetters.clear();
      _flipCardKeys
        ..clear()
        ..addAll(List.generate(
            6, (_) => List.generate(5, (_) => GlobalKey<FlipCardState>())));
    });
  }

  handleKey(RawKeyEvent key) {
    if (key.runtimeType.toString() == 'RawKeyDownEvent') {
      if (key.character != null && key.character != "") {
        _onKeyTapped(key.character.toString().toUpperCase());
      } else {
        if (key.isKeyPressed(LogicalKeyboardKey.enter)) {
          _onEnterTapped();
        } else if (key.isKeyPressed(LogicalKeyboardKey.backspace)) {
          _onDeleteTapped();
        } else if (key.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          setState(() {
            _board[_currentWordIndex].goRight();
          });
        } else if (key.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          setState(() {
            _board[_currentWordIndex].goLeft();
          });
        }
      }
      // print("why does this run twice $keyCode");
    }
  }

  @override
  void initState() {
    super.initState();
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
        body: RawKeyboardListener(
          autofocus: true,
          onKey: handleKey,
          focusNode: FocusNode(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShakeWidget(
                key: _shakeKey,
                shakeCount: 3,
                shakeOffset: 10,
                shakeDuration: const Duration(milliseconds: 400),
                child: Column(
                  children: _board
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
                                      key: _flipCardKeys[i][j],
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
                                          isSelected: word.currentIndex == j &&
                                              _currentWordIndex == i,
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
                onKeyTapped: _onKeyTapped,
                onEnterTapped: _onEnterTapped,
                onDeleteTapped: _onDeleteTapped,
                letters: _keyboardLetters,
              ),
            ],
          ),
        ));
  }
}
