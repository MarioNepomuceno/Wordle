import 'package:equatable/equatable.dart';

import 'letter_model.dart';

class Word extends Equatable {
  final List<Letter> letters;
  int currentIndex;

  Word({
    required this.letters,
    this.currentIndex = 0,
  });

  factory Word.fromString(String word) => Word(
        letters: word
            .split('')
            .map(
              (e) => Letter(val: e),
            )
            .toList(),
      );

  String get wordString => letters.map((e) => e.val).join();

  void changeLetter(int index) {
    currentIndex = index;
  }

  void goRight() {
    if (currentIndex != letters.length - 1) {
      currentIndex++;
    }
  }

  void goLeft() {
    if (currentIndex != 0) {
      currentIndex--;
    }
  }

  void addLetter(String val) {
    if (currentIndex < letters.length) {
      letters[currentIndex] = Letter(val: val);
      if (currentIndex != letters.length - 1) {
        currentIndex++;
      }
    }
  }

  void removeLetter() {
    if (currentIndex >= 0) {
      if (letters[currentIndex] == Letter.empty()) {
        if (currentIndex != 0) {
          currentIndex--;
        }
      } else {
        letters[currentIndex] = Letter.empty();
      }
    }
  }

  @override
  List<Object?> get props => [letters];
}
