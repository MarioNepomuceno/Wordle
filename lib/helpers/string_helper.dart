extension StringExtensions on String {
  String removeSpecials() {
    final newString = replaceAllMapped(RegExp(r'[ãÃáÁàÀââ]'), (match) {
      return 'A';
    }).replaceAllMapped(RegExp(r'[éÉèÈêÊ]'), (match) {
      return 'E';
    }).replaceAllMapped(RegExp(r'[óÓõÕòÒôÔ]'), (match) {
      return 'O';
    }).replaceAllMapped(RegExp(r'[íÍìÌ]'), (match) {
      return 'I';
    }).replaceAllMapped(RegExp(r'[úÚùÙ]'), (match) {
      return 'I';
    }).replaceAllMapped(RegExp(r'[ç]'), (match) {
      return 'C';
    });

    return newString;
  }
}
