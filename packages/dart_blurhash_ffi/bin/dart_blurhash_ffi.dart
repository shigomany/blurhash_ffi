import 'dart:io';

void main() {
  const actual = 'LGF5]+Yk^6#M@-5c,1J5@[or[Q6.';
  final fileBytes = File('assets/test1.jpg').readAsBytesSync();
  print(fileBytes);
}
