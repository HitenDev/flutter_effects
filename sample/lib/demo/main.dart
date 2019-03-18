import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Blog Demo'),
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
                              child: Text(
                                "Text",
                                style: TextStyle(color: Colors.white),
                              ))),
                    )));
          },
          itemCount: 10),
    );
  }
}

class _CustomRenderObjectWidget extends SingleChildRenderObjectWidget {
  final Widget child;

  _CustomRenderObjectWidget({this.child}) : super(child: child);
  @override
  RenderObject createRenderObject(BuildContext context) {
    return _CustomRenderObject();
  }
}

class _CustomRenderObject extends RenderProxyBox {
  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    print(offset);
    context.canvas.drawCircle(offset, 3, Paint()..color = Colors.red);
  }
}

class _BorderLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset.zero, 3, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
