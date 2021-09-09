import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MyBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white60,
          borderRadius: BorderRadius.all(
              Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 5),
              blurRadius: 50,
              color: Color(0xFF12153D).withOpacity(0.2),
            ),
          ]),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 8.0),
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
      ),
    );
  }
}
