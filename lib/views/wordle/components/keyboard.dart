import 'package:flutter/material.dart';

import '../../../models/letter_model.dart';

const _qwerty = [
  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', '<-'],
  ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'ENTER']
];

class Keyboard extends StatelessWidget {
  const Keyboard({
    Key? key,
    required this.onKeyTapped,
    required this.onDeleteTapped,
    required this.onEnterTapped,
    required this.letters,
  }) : super(key: key);

  final void Function(String) onKeyTapped;
  final VoidCallback onDeleteTapped;
  final VoidCallback onEnterTapped;

  final Set<Letter> letters;

  @override
  Widget build(BuildContext context) {
    return Column(
        children: _qwerty
            .map(
              (keyRow) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: keyRow.map(
                  (letter) {
                    if (letter == '<-') {
                      return _KeyBoardButton.delete(onTap: onDeleteTapped);
                    } else if (letter == 'ENTER') {
                      return _KeyBoardButton.enter(
                        onTap: onEnterTapped,
                        height: MediaQuery.of(context).size.height * 0.06,
                      );
                    }
                    final letterKey = letters.firstWhere((e) => e.val == letter,
                        orElse: () => Letter.empty());

                    return _KeyBoardButton(
                      onTap: () => onKeyTapped(letter),
                      letter: letter,
                      backgroundColor: letterKey != List.empty()
                          ? letterKey.backgroundColor
                          : Colors.grey,
                      height: MediaQuery.of(context).size.height * 0.05,
                    );
                  },
                ).toList(),
              ),
            )
            .toList());
  }
}

class _KeyBoardButton extends StatelessWidget {
  const _KeyBoardButton({
    Key? key,
    this.height = 60,
    this.width = 50,
    required this.onTap,
    required this.backgroundColor,
    required this.letter,
  }) : super(key: key);

  factory _KeyBoardButton.delete({required VoidCallback onTap}) =>
      _KeyBoardButton(
        width: 56,
        height: 30,
        onTap: onTap,
        backgroundColor: const Color.fromARGB(255, 209, 81, 81),
        letter: 'Apagar',
      );

  factory _KeyBoardButton.enter({
    required VoidCallback onTap,
    required double height,
  }) =>
      _KeyBoardButton(
          height: height,
          onTap: onTap,
          backgroundColor: Colors.greenAccent,
          letter: 'ENTER');

  final double height;
  final double width;

  final VoidCallback onTap;

  final Color backgroundColor;

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 2.0),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: height,
            width: width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 212, 212, 212),
              ),
            ),
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
