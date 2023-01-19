import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

void main() {
  runApp(const PasswordGeneratorApp());
}

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Password Generator",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const PasswordGenerator(title: "Password Generator"),
    );
  }
}

class PasswordGenerator extends StatefulWidget {
  const PasswordGenerator({super.key, required this.title});

  final String title;

  @override
  State<PasswordGenerator> createState() => _PasswordGeneratorState();
}

class _PasswordGeneratorState extends State<PasswordGenerator> {
  bool _letter = true;
  bool _number = true;
  bool _special = true;
  bool _avoidAmbiguous = false;
  double _passwordLength = 8;
  String _generatedPassword = "";

  final _letterLowerCaseSet = "abcdefghijklmnopqrstuvwxyz";
  final _letterUpperCaseSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  final _numberSet = "0123456789";
  final _specialSet = "@#%^*>\$@?/[]=+";

  final _unAmbiguousLetterLowerCaseSet = "abcdefghijkmnpqrstuvwxyz";
  final _unAmbiguousLetterUpperCaseSet = "ABCDEFGHJKLMNPQRSTUVWXYZ";
  final _unAmbiguousNumberSet = "23456789";

  final _uncheckErrorMessage = "Unable to uncheck this option!";

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _generatePassword();
    super.initState();
  }

  void _updateCheckOption(String option) {
    switch (option) {
      case "letter":
        if (!_number && !_special) {
          _showSnackBar(context, _uncheckErrorMessage);
          return;
        }
        setState(() {
          _letter = !_letter;
        });
        _generatePassword();
        break;
      case "number":
        if (!_letter && !_special) {
          _showSnackBar(context, _uncheckErrorMessage);
          return;
        }
        setState(() {
          _number = !_number;
        });
        _generatePassword();
        break;
      case "special":
        if (!_letter && !_number) {
          _showSnackBar(context, _uncheckErrorMessage);
          return;
        }
        setState(() {
          _special = !_special;
        });
        _generatePassword();
        break;
      case "ambiguous":
        setState(() {
          _avoidAmbiguous = !_avoidAmbiguous;
        });
        _generatePassword();
        break;
      default:
    }
  }

  void _generatePassword() {
    String chars = "";

    if (_avoidAmbiguous) {
      if (_letter) {
        chars += "$_unAmbiguousLetterLowerCaseSet$_unAmbiguousLetterUpperCaseSet";
      }
      if (_number) {
        chars += _unAmbiguousNumberSet;
      }
    } else {
      if (_letter) {
        chars += "$_letterLowerCaseSet$_letterUpperCaseSet";
      }
      if (_number) {
        chars += _numberSet;
      }
    }
    if (_special) {
      chars += _specialSet;
    }
    _generatedPassword = List.generate(_passwordLength.toInt(), (index) {
      final int indexRandom = Random.secure().nextInt(chars.length);
      return chars[indexRandom];
    }).join("");
    _controller.text = _generatedPassword;
  }

  void _showSnackBar(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _letter,
                  onChanged: (bool? value) {
                    _updateCheckOption("letter");
                  },
                ),
                const Text("Letter"),
                Checkbox(
                  value: _number,
                  onChanged: (bool? value) {
                    _updateCheckOption("number");
                  },
                ),
                const Text("Number"),
                Checkbox(
                  value: _special,
                  onChanged: (bool? value) {
                    _updateCheckOption("special");
                  },
                ),
                const Text("Special"),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _avoidAmbiguous,
                  onChanged: (bool? value) {
                    _updateCheckOption("ambiguous");
                  },
                ),
                const Text("Avoid Ambiguous"),
                Slider(
                  value: _passwordLength,
                  max: 100,
                  divisions: 100,
                  label: _passwordLength.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _passwordLength = value;
                    });
                    _generatePassword();
                  },
                ),
                Text(("Length ${_passwordLength.round()}"))
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Center(
                child: TextFormField(
                  readOnly: true,
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _generatedPassword));
                    _showSnackBar(context, "Copied to Clipboard");
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
