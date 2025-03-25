import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quiver/async.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 73, 53, 255)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Meeting App'),
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
  bool recording = false;
  int _time = 0;

  requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.microphone,
    ].request();
    log(statuses.toString());
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    startTimer();
  }

  void startTimer() {
    CountdownTimer countDownTimer = CountdownTimer(
      const Duration(seconds: 1000),
      const Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() => _time++);
    });

    sub.onDone(() {
      print("Done");
      sub.cancel();
    });
  }

  var jitsiMeet = JitsiMeet();
  var options = JitsiMeetConferenceOptions(room: 'tejas268');
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Screen Recording'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Time: $_time\n'),
            !recording
                ? Center(
                    child: ElevatedButton(
                      child: const Text("Record Screen"),
                      onPressed: () => startScreenRecord(false),
                    ),
                  )
                : Container(),
            Center(
              child: ElevatedButton(
                child: const Text("Connect meeting"),
                onPressed: () {
                  jitsiMeet.join(options);
                },
              ),
            ),
            !recording
                ? Center(
                    child: ElevatedButton(
                      child: const Text("Record Screen & audio"),
                      onPressed: () => startScreenRecord(true),
                    ),
                  )
                : Center(
                    child: ElevatedButton(
                      child: const Text("Stop Record"),
                      onPressed: () => stopScreenRecord(),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  startScreenRecord(bool audio) async {
    bool start = false;

    if (audio) {
      start = await FlutterScreenRecording.startRecordScreenAndAudio("Title");
    } else {
      start = await FlutterScreenRecording.startRecordScreen("Title");
    }

    if (start) {
      setState(() => recording = !recording);
    }

    return start;
  }

  stopScreenRecord() async {
    String path = await FlutterScreenRecording.stopRecordScreen;
    setState(() {
      recording = !recording;
    });
    print("Opening video");
    print(path);
    OpenFile.open(path);
  }
}
