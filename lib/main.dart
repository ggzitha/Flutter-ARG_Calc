import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Kalibrasi ARG app',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(title: 'Kalibrasi ARG Home'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  num phis = math.pi;
  num result_diameter = 0.0;
  num tip_diameter = 0.0;

  num final_results = 0.0;
  String final_results_string = "";

  String _dropdownValue = "0.00";
  List<String> dropDownOptions = [
    "0.00",
    "0.10",
    "0.20",
    "0.50",
  ];

  void dropdownCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        _dropdownValue = selectedValue;
        tip_diameter = double.parse(selectedValue);
      });
    }
  }

  void _processCalc() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    setState(() {
      final_results =
          (phis * math.pow((result_diameter / 2), 2)) * (tip_diameter / 1000);
      final_results_string =
          'volume : ' + final_results.toStringAsFixed(3) + ' mm/Jungkit';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: (MediaQuery.of(context).size.height),
          width: (MediaQuery.of(context).size.width),
          decoration: const BoxDecoration(
//             color: snapshot.data.color,
            image: DecorationImage(
//               image: AssetImage("assets/overlay.png"),

              image: AssetImage("assets/images/bg_Arg.png"),

              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            title: const Text('Kalibrasi ARG'),
            // backgroundColor: const Color(0xFF121F2B),
            backgroundColor: Color.fromARGB(40, 0, 0, 0), elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Info',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: const <Widget>[
                            Text('Volume (V) = Luas Corong X resolusiARG',
                                style: TextStyle(fontSize: 13)),
                            Text(''),
                            Text('V = (π x (diameter/2)² ) x (0.1|0.2|0.3)',
                                style: TextStyle(fontSize: 13)),
                            Text(''),
                            Text(''),
                            Text(''),
                            Text('@Mee',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 9)),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Share',
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(children: <Widget>[
              SizedBox(
                height: 100,
              ),

              // Text("Resolusi Alat: $_dropdownValue"),
              Text("Resolusi Alat (Per Tip) :", style: TextStyle(fontSize: 15)),
              DropdownButton(
                items: dropDownOptions
                    .map<DropdownMenuItem<String>>((String mascot) {
                  return DropdownMenuItem<String>(
                      child: Text(
                        mascot,
                        style: TextStyle(fontSize: 20),
                      ),
                      value: mascot);
                }).toList(),
                value: _dropdownValue,
                onChanged: dropdownCallback,
                style: const TextStyle(
                  color: Colors.blue,
                ),
              ),

              SizedBox(
                height: 75,
              ),

              ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 90),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                  autofocus: true,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Diameter',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,4}')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      try {
                        final text = newValue.text;
                        if (text.isNotEmpty) double.parse(text);
                        result_diameter = double.parse(text);
                        return newValue;
                      } catch (e) {}
                      // return oldValue;
                      FocusManager.instance.primaryFocus?.unfocus();
                      return TextEditingValue.empty;
                    }),
                  ],
                ),
              ),
              SizedBox(
                height: 150,
              ),

              Text(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.lightBlue,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationThickness: 2,
                  fontSize: 25,
                  backgroundColor: Color(0xffb0b0b7),
                ),
                //  result_diameter.toString()

                ' $final_results_string',
              ),
            ]),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _processCalc,
            tooltip: 'Process',
            child: const Icon(Icons.check),
          ),
        )
      ],
    );
  }
}
