import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mali/helpers/string_helper.dart';
import 'package:mali/models/game_option.dart';

import '../components/shaking.dart';
import '../data/words.dart';
import '../data/wordsall.dart';
import '../helpers/colors_helper.dart';
import '../models/enum/game_status.dart';
import '../models/enum/letter_status.dart';
import '../models/letter_model.dart';
import '../models/word_model.dart';

abstract class WordleListener {
  void showSnackBar(Color color, String titleText, String buttonText);
}

class WordleController extends ChangeNotifier {
  WordleListener? _listener;

  void setListener(WordleListener listener) {
    _listener = listener;
  }

  final shakeKey = GlobalKey<ShakeWidgetState>();
  final focusNode = FocusNode();

  GameOptions gameOptions = GameOptions();
  GameStatus gameStatus = GameStatus.playing;
  int currentWordIndex = 0;

  final List<Word> board = List.generate(
    6,
    (_) => Word(
      letters: List.generate(
        5,
        (_) => Letter.empty(),
      ),
    ),
  );

  Word? get currentWord =>
      currentWordIndex < board.length ? board[currentWordIndex] : null;

  Word solution = Word.fromString(
      // fiveLetterWords[Random().nextInt(fiveLetterWords.length)].toUpperCase(),
      "MARIO");

  final List<List<GlobalKey<FlipCardState>>> flipCardKeys = List.generate(
    6,
    (_) => List.generate(
      5,
      (_) => GlobalKey<FlipCardState>(),
    ),
  );

  final Set<Letter> keyboardLetters = {};

  void onKeyTapped(String key) {
    if (gameStatus == GameStatus.playing) {
      currentWord?.addLetter(key);
      notifyListeners();
    }
  }

  void onDeleteTapped() {
    if (gameStatus == GameStatus.playing) {
      currentWord?.removeLetter();
      notifyListeners();
    }
  }

  void onCardTapped(Word word, int i) {
    word.changeLetter(i);
    notifyListeners();
  }

  Future<void> onEnterTapped() async {
    String exists = fiveLetterWordsAll.firstWhere(
        (element) =>
            element.removeSpecials() ==
            currentWord!.wordString.removeSpecials(),
        orElse: () => "");

    if (exists != "" || gameOptions.allowAnyWord) {
      if (gameStatus == GameStatus.playing &&
          !currentWord!.letters.contains(Letter.empty())) {
        gameStatus = GameStatus.submitting;

        for (var i = 0; i < currentWord!.letters.length; i++) {
          final currentWordLetter = currentWord!.letters[i];
          final currentSolutionLetter = solution.letters[i];

          if (currentWordLetter.val.removeSpecials() ==
              currentSolutionLetter.val.removeSpecials()) {
            currentWord!.letters[i] = currentWordLetter.copyWith(
              val: currentSolutionLetter.val,
              status: LetterStatus.correct,
            );
          } else if (solution.letters.contains(currentWordLetter)) {
            if (solution.letters
                    .where((element) => element.val == currentWordLetter.val)
                    .length ==
                currentWord!.letters
                    .where((element) =>
                        element.val == currentWordLetter.val &&
                        element.status == LetterStatus.correct)
                    .length) {
              currentWord!.letters[i] =
                  currentWordLetter.copyWith(status: LetterStatus.notInWord);
            } else {
              currentWord!.letters[i] =
                  currentWordLetter.copyWith(status: LetterStatus.inWord);
            }
          } else {
            currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.notInWord);
          }

          notifyListeners();

          final letter = keyboardLetters.firstWhere(
              (e) => e.val == currentWordLetter.val,
              orElse: () => Letter.empty());
          if (letter.status != LetterStatus.correct) {
            keyboardLetters.removeWhere((e) => e.val == currentWordLetter.val);
            keyboardLetters.add(currentWord!.letters[i]);
          }

          await Future.delayed(
            Duration(milliseconds: i * 150),
            () => flipCardKeys[currentWordIndex][i].currentState?.toggleCard(),
          );
        }

        _checkIfWinOrLoss();
      }
    } else {
      shakeKey.currentState?.shake();
    }
  }

  void _checkIfWinOrLoss() {
    if (currentWord!.wordString == solution.wordString) {
      gameStatus = GameStatus.won;
      _listener!.showSnackBar(correctColor, "Você ganhou!", "Novo Jogo");
    } else if (currentWordIndex + 1 >= board.length) {
      gameStatus = GameStatus.lost;
      _listener!.showSnackBar(correctColor,
          'Você perdeu! Solução: ${solution.wordString}', "Novo Jogo");
    } else {
      gameStatus = GameStatus.playing;
    }

    currentWordIndex += 1;
    notifyListeners();
  }

  void restart() {
    gameStatus = GameStatus.playing;
    currentWordIndex = 0;
    board
      ..clear()
      ..addAll(
        List.generate(
          6,
          (_) => Word(
            letters: List.generate(
              5,
              (_) => Letter.empty(),
            ),
          ),
        ),
      );
    solution = Word.fromString(
      fiveLetterWords[Random().nextInt(fiveLetterWords.length)].toUpperCase(),
    );
    keyboardLetters.clear();
    flipCardKeys
      ..clear()
      ..addAll(
        List.generate(
          6,
          (_) => List.generate(
            5,
            (_) => GlobalKey<FlipCardState>(),
          ),
        ),
      );

    notifyListeners();
  }

  handleKey(RawKeyEvent key) {
    if (key.runtimeType.toString() == 'RawKeyDownEvent') {
      if (key.character != null && key.character != "") {
        onKeyTapped(key.character.toString().toUpperCase());
      } else {
        if (key.isKeyPressed(LogicalKeyboardKey.enter)) {
          onEnterTapped();
        } else if (key.isKeyPressed(LogicalKeyboardKey.backspace)) {
          onDeleteTapped();
        } else if (key.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          board[currentWordIndex].goRight();
          notifyListeners();
        } else if (key.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          board[currentWordIndex].goLeft();
          notifyListeners();
        }
      }
    }
  }

  changeAllowAnyWord() {
    gameOptions.allowAnyWord = !gameOptions.allowAnyWord;
    notifyListeners();
  }

  changeShowSpecialCharacters() {
    gameOptions.showSpecialCharacters = !gameOptions.showSpecialCharacters;
    notifyListeners();
  }
}
