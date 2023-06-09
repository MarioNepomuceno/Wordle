import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../helpers/colors_helper.dart';
import 'enum/letter_status.dart';

class Letter extends Equatable {
  const Letter({
    required this.val,
    this.status = LetterStatus.initial,
  });

  factory Letter.empty() => const Letter(val: '');

  final String val;
  final LetterStatus status;

  Color get backgroundColor {
    switch (status) {
      case LetterStatus.initial:
        return const Color.fromARGB(255, 206, 206, 206);
      case LetterStatus.notInWord:
        return notInWordColor;
      case LetterStatus.inWord:
        return inWordColor;
      case LetterStatus.correct:
        return correctColor;
    }
  }

  Color get textColor {
    if (status == LetterStatus.notInWord) {
      return const Color.fromARGB(255, 99, 99, 99);
    } else {
      return Colors.black;
    }
  }

  Color get borderColor {
    switch (status) {
      case LetterStatus.initial:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  Letter copyWith({String? val, LetterStatus? status}) {
    return Letter(
      val: val ?? this.val,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [val];
}
