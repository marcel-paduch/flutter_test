import 'dart:collection';

import 'package:flutter/material.dart';

class SymptomsState extends State<SymptomsWidget> {
  static const String _title = 'Symptoms aggregator';
  final Map<String, int> symptomsMap = LinkedHashMap();
  final TextStyle _biggerFont = const TextStyle(fontSize: 16);

  Widget _symptomsList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: symptomsMap.length,
        itemBuilder: (BuildContext _context, int i) {
          String symptom = symptomsMap.keys.elementAt(i);
          return _buildRow(symptom, symptomsMap[symptom]);
        });
  }

  Widget _buildRow(String symptom, int level) {
    return Card(
      child: ListTile(
        title: Text(
          symptom,
          style: _biggerFont,
        ),
        leading: Icon(Icons.assignment_late),
        trailing: NumberIndicatorWidget(level, 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_title)),
      floatingActionButton: MyFloatingActionButtonWidget(
        callback: callbackMethod,
      ),
      body: _symptomsList(),
    );
  }

  callbackMethod(String symptom, int lvl) => setState(() {
        symptomsMap[symptom] = lvl;
      });
}

class NumberIndicatorWidget extends StatelessWidget {
  final int _currentLvl;
  final int _maxLvl;

  NumberIndicatorWidget(this._currentLvl, this._maxLvl) {
    assert(this._maxLvl >= this._currentLvl);
  }

  @override
  Widget build(BuildContext context) {
    const double _iconSize = 15;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(_maxLvl, (i) {
        return Icon(
          i < _currentLvl ? Icons.star : Icons.star_border,
          size: _iconSize,
        );
      }),
    );
  }
}

class SymptomsWidget extends StatefulWidget {
  @override
  SymptomsState createState() => SymptomsState();
}

class MyFloatingActionButtonWidget extends StatefulWidget {
  final Function callback;

  MyFloatingActionButtonWidget({Key key, this.callback}) : super(key: key);

  @override
  FloatingButtonState createState() => FloatingButtonState();
}

class FloatingButtonState extends State<MyFloatingActionButtonWidget> {
  bool showFab = true;

  @override
  Widget build(BuildContext context) {
    return showFab
        ? FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Colors.green,
            onPressed: () {
              var bottomSheetController = showBottomSheet(
                  context: context,
                  builder: (context) => BottomSheetWidget(
                        callback: widget.callback,
                      ));
              show(false);
              bottomSheetController.closed.then((value) {
                show(true);
              });
            },
          )
        : Container();
  }

  void show(bool value) {
    setState(() {
      showFab = value;
    });
  }
}

class BottomSheetWidget extends StatefulWidget {
  final Function callback;

  BottomSheetWidget({Key key, this.callback}) : super(key: key);

  @override
  BottomSheetState createState() => BottomSheetState();
}

class BottomSheetState extends State<BottomSheetWidget> {
  final _myController = TextEditingController();

  double _sliderValue = 5.0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.grey[300], spreadRadius: 5)
          ]),
      child: Column(children: [
        DecoratedTextField(_myController),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Slider(
                onChanged: (newRating) {
                  setState(() => _sliderValue = newRating);
                },
                value: _sliderValue,
                activeColor: Colors.indigoAccent,
                min: 1.0,
                max: 10.0,
              ),
            ),
            Container(
                width: 50,
                child: Text(
                  _sliderValue.round().toString(),
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ))
          ],
        ),
        RaisedButton(
          onPressed: () =>
              widget.callback(_myController.text, _sliderValue.round()),
          child: Text("Save"),
        ),
      ]),
    );
  }
}

class DecoratedTextField extends StatelessWidget {
  final _myController;

  DecoratedTextField(this._myController);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        child: TextField(
          controller: _myController,
          decoration: InputDecoration.collapsed(
            hintText: 'Enter your symptom',
          ),
        ));
  }
}
