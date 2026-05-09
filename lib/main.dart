/* 
  Simple Unit Converter app (Flutter)
  Run instructions:
   1. From the project root run: flutter pub get
   2. Launch on an emulator/device: flutter run
   3. Take a screenshot of the running app for your Word document deliverable.
   4. Commit code to GitHub and include the repo URL in your documentation.
  Rubric notes:
   - Application Requirement Delivery: 20%
   - Coding Standards: 40%
   - Runtime, Correctness, Submission: 40%
*/

import 'package:flutter/material.dart';

void main() {
  // Helpful console output to verify run; visible in your terminal when you run the app.
  debugPrint('Starting Unit Converter app...');
  debugPrint('Run instructions: flutter pub get && flutter run');
  runApp(ConverterApp());
}

class ConverterApp extends StatelessWidget {
  // Root widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Converter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ConverterHomePage(),
    );
  }
}

class ConverterHomePage extends StatefulWidget {
  @override
  _ConverterHomePageState createState() => _ConverterHomePageState();
}

class _ConverterHomePageState extends State<ConverterHomePage> {
  // Supported categories and units
  final Map<String, List<String>> categories = {
    'Distance': ['Kilometers', 'Miles'],
    'Weight': ['Kilograms', 'Pounds'],
    'Temperature': ['Celsius', 'Fahrenheit'],
  };

  String selectedCategory = 'Distance';
  String fromUnit = 'Kilometers';
  String toUnit = 'Miles';
  final TextEditingController _inputCtrl = TextEditingController(text: '1');
  String result = '';

  @override
  void initState() {
    super.initState();
    _computeResult(); // initial compute
    _inputCtrl.addListener(_computeResult);
    // Show a short SnackBar after first frame to confirm the app started (visible on device/emulator).
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Use ScaffoldMessenger to show a brief message once on startup.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unit Converter started — enter a value to convert'),
          duration: Duration(seconds: 2),
        ),
      );
      debugPrint('SnackBar shown: Unit Converter started.');
    });
  }

  @override
  void dispose() {
    // remove listener explicitly before disposing controller
    _inputCtrl.removeListener(_computeResult);
    _inputCtrl.dispose();
    super.dispose();
  }

  // Conversion dispatcher
  double _convert(double value, String category, String from, String to) {
    if (category == 'Distance') {
      // km <-> miles
      if (from == to) return value;
      if (from == 'Kilometers' && to == 'Miles') return value / 1.609344;
      if (from == 'Miles' && to == 'Kilometers') return value * 1.609344;
    } else if (category == 'Weight') {
      // kg <-> lb
      if (from == to) return value;
      if (from == 'Kilograms' && to == 'Pounds') return value * 2.2046226218;
      if (from == 'Pounds' && to == 'Kilograms') return value / 2.2046226218;
    } else if (category == 'Temperature') {
      // C <-> F
      if (from == to) return value;
      if (from == 'Celsius' && to == 'Fahrenheit') return value * 9 / 5 + 32;
      if (from == 'Fahrenheit' && to == 'Celsius') return (value - 32) * 5 / 9;
    }
    return value;
  }

  void _computeResult() {
    final text = _inputCtrl.text;
    // text is non-nullable; check only for emptiness
    if (text.trim().isEmpty) {
      setState(() => result = '');
      return;
    }
    final parsed = double.tryParse(text);
    if (parsed == null) {
      setState(() => result = 'Invalid input');
      return;
    }
    final converted = _convert(parsed, selectedCategory, fromUnit, toUnit);
    setState(() => result = converted.toStringAsPrecision(12).replaceFirst(RegExp(r'\.?0+$'), ''));
  }

  void _onCategoryChanged(String? newCat) {
    if (newCat == null) return;
    setState(() {
      selectedCategory = newCat;
      fromUnit = categories[newCat]![0];
      toUnit = categories[newCat]!.length > 1 ? categories[newCat]![1] : categories[newCat]![0];
    });
    _computeResult();
  }

  void _swapUnits() {
    setState(() {
      final tmp = fromUnit;
      fromUnit = toUnit;
      toUnit = tmp;
    });
    _computeResult();
  }

  @override
  Widget build(BuildContext context) {
    final units = categories[selectedCategory]!;
    return Scaffold(
      appBar: AppBar(title: Text('Conversion App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Category selector
            Row(
              children: [
                Text('Measure: ', style: TextStyle(fontSize: 16)),
                SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: categories.keys
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: _onCategoryChanged,
                ),
              ],
            ),

            SizedBox(height: 20),

            // From row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _inputCtrl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Value',
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: fromUnit,
                    items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => fromUnit = v);
                      _computeResult();
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Swap button and equal sign
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Swap units',
                  icon: Icon(Icons.swap_horiz),
                  onPressed: _swapUnits,
                ),
                SizedBox(width: 8),
                Text('→', style: TextStyle(fontSize: 24)),
              ],
            ),

            SizedBox(height: 12),

            // To row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      result.isEmpty ? 'Result' : result,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: toUnit,
                    items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => toUnit = v);
                      _computeResult();
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Helpful note and example
            Text(
              'Example: convert miles ↔ kilometers, kilograms ↔ pounds, Celsius ↔ Fahrenheit',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
