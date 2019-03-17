# flutter effects

A flutter package which contains a collection of some cool and beautiful effects; support `android` and `ios` .

##  Screenshot

| type | support child | screenshot |
| :--: | :--: | :--: |
| diffscale | text | <img src="https://upload-images.jianshu.io/upload_images/869487-f41550a78cd70799.gif?imageMogr2/auto-orient/strip"  width = "100%"> |
| borderline |  any |<img src="https://upload-images.jianshu.io/upload_images/869487-72674e439250aff0.gif?imageMogr2/auto-orient/strip" width = "100%"> |
| rainbow  | text | <img src="https://upload-images.jianshu.io/upload_images/869487-b76a646d0b3673fb.gif?imageMogr2/auto-orient/strip"  width = "100%"> |
| explosion  | any | <img src="https://upload-images.jianshu.io/upload_images/869487-c37dcb66a539d946.gif?imageMogr2/auto-orient/strip"  width = "100%"> | 
| anvil  | any |  <img src="https://upload-images.jianshu.io/upload_images/869487-5017dbebd79dcf3c.gif?imageMogr2/auto-orient/strip"  width = "100%"> | 
| scratchcard | any | <img src="https://upload-images.jianshu.io/upload_images/869487-5cb0aeafb78e8dd3.gif?imageMogr2/auto-orient/strip"  width = "100%"> | 
| more | more | waiting |


## Usage

### diffscale

```dart

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

DiffScaleText(
  text: sentences[diffScaleNext % sentences.length],
  textStyle: TextStyle(fontSize: 20, color: Colors.blue),
)

```
Note:the variable `diffScaleNext` control next position;

### borderline

```dart
LineBorderText(
    child: Text(
      "Border Effect",
      style: TextStyle(fontSize: 20),
    ),
    autoAnim: true)
```

### rainbow

```dart
RainbowText(colors: [
  Color(0xFFFF2B22),
  Color(0xFFFF7F22),
  Color(0xFFEDFF22),
  Color(0xFF22FF22),
  Color(0xFF22F4FF),
  Color(0xFF5400F7),
], text: "Welcome to BBT", loop: true)

```

### explosion

```dart
ExplosionWidget(
    tag: "Explosion Text",
    child: Container(
        alignment: Alignment.center,
        color: Colors.blueAccent,
        child: Text(
          "Explosion Text",
          style: TextStyle(
              fontSize: 20,
              color: Colors.red,
              fontWeight: FontWeight.bold),
        )))
```

### anvil

```dart
        
AnvilEffectWidget(child: Text(
      "👉AnvilEffect👈",
      style: TextStyle(color: Colors.white, fontSize: 20),
    )

```

### scratchcard

```dart
ScratchCardWidget(
    strokeWidth: 20,
    threshold: 0.5,
    foreground: (canvas, size, offset) {
      if (_image != null) {
        double scale;
        double dx = 0;
        double dy = 0;
        if (_image.width * size.height >
            size.width * _image.height) {
          scale = size.height / _image.height;
          dx = (size.width - _image.width * scale) / 2;
        } else {
          scale = size.width / _image.width;
          dy = (size.height - _image.height * scale) / 2;
        }
        canvas.save();
        canvas.translate(dx, dy);
        canvas.scale(scale, scale);
        canvas.drawImage(_image, Offset(0, 0), new Paint());
        canvas.restore();
      } else {
        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Paint()
              ..color = Colors.grey);
      }
    },
    child: Container(
      color: Colors.blueAccent,
      alignment: Alignment.center,
      child: Image.asset(
        "assets/images/icon_sm_sigin_status_three.png",
        fit: BoxFit.scaleDown, height: 20,),
    ))
    
```
- strokeWidth  : paint's strokewidth
- threshold :  the threshold to clear the foreground covering
- foreground : draw foreground covering
- child : draw child

## <div align="center">More flutter effects are under development, so stay tuned! please follow me.</div><br>

# Author
- Name: Hiten
- Blog: https://juejin.im/user/595a16125188250d944c6997
- Email: zzdxit@gmail.com 

# License

This project is licensed under the [Apache Software License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

See [`LICENSE`](LICENSE) for full of the license text.
