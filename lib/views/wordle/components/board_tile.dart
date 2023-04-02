import 'package:flutter/material.dart';

import '../../../models/letter_model.dart';

class BoardTile extends StatelessWidget {
  const BoardTile({
    Key? key,
    required this.letter,
    required this.isSelected,
  }) : super(key: key);

  final Letter letter;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.height * 0.1,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: letter.backgroundColor,
        border: Border.all(
          color: letter.borderColor,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              letter.val,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isSelected)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 3,
                color: const Color.fromARGB(255, 49, 49, 49),
              ),
            )
        ],
      ),
    );
  }
}
