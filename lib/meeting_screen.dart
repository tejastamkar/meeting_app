import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart'; // To open recorded file

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final JitsiMeet _jitsiMeet = JitsiMeet();
  bool _isRecording = false;
  bool _isMeetingActive = false;
  String? _recordedFilePath; // Store recorded file path

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startMeeting() async {
    await _requestPermissions();
    // _startScreenRecording(); // Start recording before meeting starts
    _joinMeeting();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.mediaLibrary,
      if (Platform.isAndroid) Permission.systemAlertWindow,
    ].request();
  }

  Future<void> _startScreenRecording() async {
    try {
      bool started = await FlutterScreenRecording.startRecordScreenAndAudio(
        "meeting_record",
      );
      if (started) {
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      debugPrint("Error starting screen recording: $e");
    }
  }

  Future<void> _stopScreenRecording() async {
    try {
      String filePath = await FlutterScreenRecording.stopRecordScreen;
      setState(() {
        _isRecording = false;
        _recordedFilePath = filePath;
      });
      _openRecordedFile();
      log("Recording saved at: $filePath");
    } catch (e) {
      log("Error stopping screen recording: $e");
    }
  }

  Future<void> _joinMeeting() async {
    try {
      var options = JitsiMeetConferenceOptions(
        // serverURL: "https://vc.sanpri.in",
        serverURL: "https://meet.jit.si",
        configOverrides: {
          "startWithAudioMuted": false,
          "startWithVideoMuted": false,
          "pictureInPicture.enabled": true,
        },

        featureFlags: {"unsafe-room-warning.enabled": true},
        room: 'testvoice',
        // room: 'tejas268',
      );

      await _jitsiMeet.join(
        options,
        JitsiMeetEventListener(
          conferenceJoined: (url) {
            setState(() {
              _isMeetingActive = true;
            });
            _startScreenRecording(); // 🔥 Start recording AFTER meeting starts
          },
          conferenceTerminated: (url, error) {
            setState(() {
              _isMeetingActive = false;
              _isRecording = false;
            });
            _stopScreenRecording();
          },
        ),
      );
    } catch (error) {
      debugPrint("Error joining meeting: $error");
    }
  }

  Future<void> _endMeeting() async {
    await _jitsiMeet.hangUp();
    setState(() {
      _isMeetingActive = false;
      _isRecording = false;
    });
    _stopScreenRecording(); // Stop recording manually
  }

  Future<void> _openRecordedFile() async {
    if (_recordedFilePath != null && File(_recordedFilePath!).existsSync()) {
      OpenFile.open(_recordedFilePath!);
    } else {
      debugPrint("No recorded file found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meeting Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isMeetingActive)
              Text(
                'Meeting in progress',
                style: TextStyle(color: Colors.green, fontSize: 20),
              ),
            if (_isRecording)
              Text(
                'Recording in progress...',
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isMeetingActive ? null : _startMeeting,
              child: Text('Start Meeting'),
            ),
            ElevatedButton(
              onPressed: _isMeetingActive ? _endMeeting : null,
              child: Text('End Meeting'),
            ),
            ElevatedButton(
              onPressed: _stopScreenRecording,
              child: Text('End Meeting'),
            ),
          ],
        ),
      ),
    );
  }
}
