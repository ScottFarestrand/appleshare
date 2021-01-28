import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10),
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}
