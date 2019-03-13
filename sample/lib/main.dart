import 'package:flutter/material.dart';
import 'package:text_effect/flutter_text_effect.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Effect Text Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Effect Text'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> sentences;

  int diffScaleNext = 0;

  @override
  void initState() {
    super.initState();
    sentences = [
      "What is design?",
      "Design is not just",
      "what it looks like and feels like.",
      "Design is how it works. \n- Steve Jobs",
      "Older people",
      "sit down and ask,",
      "'What is it?'",
      "but the boy asks,",
      "What can I do with it?. \n- Steve Jobs",
      "Swift",
      "Objective-C",
      "iPhone",
      "iPad",
      "Mac Mini",
      "MacBook Pro",
      "Mac Pro",
      "爱老婆",
      "老婆和女儿"
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            createItem(RainbowText(colors: [
              Color(0xFFFF2B22),
              Color(0xFFFF7F22),
              Color(0xFFEDFF22),
              Color(0xFF22FF22),
              Color(0xFF22F4FF),
              Color(0xFF5400F7),
            ], text: "Welcome to BBT", loop: true)),
            Divider(),
            LineBorderText(
                child: createItem(Text(
                  "Border Effect",
                  style: TextStyle(fontSize: 20),
                )),
                autoAnim: true),
            Divider(),
            createItem(
                DiffScaleText(
                    text: sentences[diffScaleNext % sentences.length]),
                bgColor: Colors.black, onTap: () {
              setState(() {
                diffScaleNext++;
              });
            })
          ],
        ),
      ),
    );
  }

  Widget createItem(Widget child,
      {VoidCallback onTap, Color bgColor = Colors.transparent}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          color: bgColor,
          child: child,
          height: 100,
          alignment: Alignment.center,
        ));
  }
}
