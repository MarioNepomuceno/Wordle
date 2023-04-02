import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import '../../../models/enum/letter_status.dart';
import '../../../models/letter_model.dart';
import '../../../models/word_model.dart';
import 'board_tile.dart';

class Board extends StatelessWidget {
  const Board({
    Key? key,
    required this.onKeyTapped,
    required this.board,
    required this.flipCardKeys,
  }) : super(key: key);

  final void Function(String) onKeyTapped;

  final List<Word> board;
  final List<List<GlobalKey<FlipCardState>>> flipCardKeys;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: board
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
                          key: flipCardKeys[i][j],
                          flipOnTouch: false,
                          direction: FlipDirection.HORIZONTAL,
                          front: GestureDetector(
                            onTap: () {
                              word.currentIndex = i;
                            },
                            child: BoardTile(
                              letter: Letter(
                                val: letter.val,
                                status: LetterStatus.initial,
                              ),
                              isSelected: word.currentIndex == j,
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
    );
  }
}
