import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Blog Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text(widget.title))),
      body: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Container(
                alignment: Alignment.center,
                child: Transform(
                    transform: Matrix4.translationValues(100, 0, 0),
                    child: _CustomRenderObjectWidget(
                      child: Transform(
                          transform: Matrix4.translationValues(-50, 0, 0),
                          child: Container(
                              alignment: Alignment.center,
                              width: 100,
                              height: 100,
                              color: Colors.black,
                              child: const Text("Text",
                                  style: TextStyle(color: Colors.white)))),
                    )));
          },
          itemCount: 10),
    );
  }
}

class _CustomRenderObjectWidget extends SingleChildRenderObjectWidget {
  const _CustomRenderObjectWidget({Widget? child}) : super(child: child);
  @override
  RenderObject createRenderObject(BuildContext context) {
    return _CustomRenderObject();
  }
}

class _CustomRenderObject extends RenderProxyBox {
  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    // print(offset);
    context.canvas.drawCircle(offset, 3, Paint()..color = Colors.red);
  }
}
