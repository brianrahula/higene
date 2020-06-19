import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';
import 'package:video_player/video_player.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIOverlays([]);

  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => Splash(),
          '/home': (context) => Home(),
          '/camera': (context) => Camera(),
          '/video': (context) => Video(),
        });
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  bool _animate = false;
  bool _clicked = false;

  @override
  Widget build(BuildContext context) {
    if (_clicked)
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/home');
        assetsAudioPlayer.open(
          Audio('assets/audios/bgm.wav'),
          loopMode: LoopMode.single,
        );

        assetsAudioPlayer.play();
      });

    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _animate = true;
              _clicked = true;
            });
          },
          child: Lottie.network(
            'https://raw.githubusercontent.com/brianrahula/vigilant-parakeet/master/hello.json',
            width: MediaQuery.of(context).size.width / 1.5,
            animate: _animate,
          ),
        ),
      ),
    );
  }
}

final assetsAudioPlayer = AssetsAudioPlayer();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int clickedChild = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => setState(() => clickedChild = 0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Color(0xffA871D5),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 80,
                color: Color(0xff9967C2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1000),
                      child: Image.network(
                        'https://i.pinimg.com/originals/1e/bf/bf/1ebfbf434bc376f1b1357b963d864265.jpg',
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Container(color: Colors.green.shade400, height: 20,)),

                            Expanded(flex: 10, child: Container(color: Colors.black26, height: 20,)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(100)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                        child: Text('For Parents', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Card(
                      title: 'Scan',
                      onPressed: () => setState(() => clickedChild = 1),
                      onDoublePressed: () {
                        Navigator.pushNamed(context, '/camera');
                        assetsAudioPlayer.stop();
                        AssetsAudioPlayer.playAndForget(
                            Audio('assets/audios/hand_camera'));
                      },
                      clicked: (clickedChild == 1) ? true : false,
                      asset: 'scan_hand',
                    ),
                    Card(
                      title: 'Wash',
                      onPressed: () => setState(() => clickedChild = 2),
                      onDoublePressed: () {
                        Navigator.pushNamed(context, '/video');
                        assetsAudioPlayer.stop();
                      },
                      clicked: (clickedChild == 2) ? true : false,
                      asset: 'wash_hand',
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    assetsAudioPlayer.dispose();
    super.dispose();
  }
}

class Card extends StatelessWidget {
  final bool clicked;
  final Function onPressed;
  final Function onDoublePressed;
  final String asset;
  final String title;

  const Card(
      {@required this.onPressed,
      @required this.clicked,
      @required this.onDoublePressed,
      @required this.asset,
      this.title});

  @override
  Widget build(BuildContext context) {
    if (clicked) {
      AssetsAudioPlayer.playAndForget(Audio('assets/audios/$asset.wav'));
    }

    return Expanded(
      child: GestureDetector(
        onTap: clicked ? onDoublePressed : onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border:
                    Border.all(width: clicked ? 10 : 0, color: Colors.white),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10,
                      color: Color(0x1A000000),
                      offset: Offset(0, 20))
                ]),
            child: ClipRRect(
                borderRadius: clicked? BorderRadius.circular(30) :  BorderRadius.circular(40),
                child: Image.asset('assets/images/$asset.png')),
          ),
        ),
      ),
    );
  }
}

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  bool resultSent = false;

  String label;

  ImageLabeler detector = FirebaseVision.instance.imageLabeler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          assetsAudioPlayer.play();
        },
        child: SafeArea(
          child: Stack(
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.height,
                    child: CameraMlVision<List<ImageLabel>>(
                      detector: detector.processImage,
                      onResult: (List<ImageLabel> labels) {
                        if (label == 'Hand' && !resultSent) {
                          resultSent = true;
                          AssetsAudioPlayer.playAndForget(
                              Audio('assets/audios/oh_no.wav'));
                        }

                        setState(() {
                          label = labels.first.text;
                        });
                      },
                      onDispose: () {
                        detector.close();
                      },
                    )),
              ),
              if (label == 'Hand')
                Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    'assets/images/kuman.png',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.fill,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Video extends StatefulWidget {
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  int videoNumber = Random().nextInt(4);

  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/videos/video_$videoNumber.mp4')
          ..initialize().then((_) {
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    var videoContext = context;

    _controller.play();

    _controller.addListener(() {
      if (!_controller.value.isPlaying) {
        Navigator.pop(videoContext);

        assetsAudioPlayer.play();
      }
    });

    return Scaffold(
      body: Center(
        child: _controller.value.initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
