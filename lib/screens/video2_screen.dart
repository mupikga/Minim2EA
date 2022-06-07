import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/room_name_constraint.dart';
import 'package:jitsi_meet/room_name_constraint_type.dart';
import 'package:localstorage/localstorage.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class VideoScreen extends StatefulWidget {
  final String username;
  //final String mail;
  const VideoScreen({
    Key? key,
    required this.username,
    //required this.mail,
  }) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late TextEditingController serverText;
  late TextEditingController roomText;
  late TextEditingController subjectText;
  late TextEditingController nameText;
  late TextEditingController emailText;

  // Self-explainable bools
  var isAudioOnly = true;
  var isAudioMuted = true;
  var isVideoMuted = true;

  late String id;
  var storage;

  Future<User> fetchUser() async {
    storage = LocalStorage('Users');
    await storage.ready;
    id = storage.getItem('userID');
    return UserService.getUserByID(id);
  }

  @override
  void initState() {
    super.initState();

    fetchUser();
    print('...');
    // Intitalising variables
    serverText = TextEditingController();
    roomText = TextEditingController(text: "Xerra");
    subjectText = TextEditingController(text: "Community Video Call");
    nameText = TextEditingController(text: widget.username);
    emailText = TextEditingController(text: widget.username);

    JitsiMeet.addListener(JitsiMeetingListener(
        /*onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onPictureInPictureWillEnter: _onPictureInPictureWillEnter,
        onPictureInPictureTerminated: _onPictureInPictureTerminated,
        onError: _onError*/
        ));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Community Video Call'),
          foregroundColor: Colors.black.withOpacity(0.5),
          backgroundColor: Color.fromARGB(255, 255, 255, 255)),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Container(
                child: Text(
                  "Join Meet Call",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 35,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.fromLTRB(32, 10, 32, 20),
              ),
              Container(
                width: 350,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xfff3f3f3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: nameText,
                  maxLines: 1,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      suffixIcon: Icon(Icons.person, color: Colors.black),
                      hintText: "Name"),
                ),
              ),
              const Spacer(flex: 58),
              Row(
                children: [
                  const Spacer(flex: 32),
                  GestureDetector(
                    onTap: () {
                      _onAudioMutedChanged(!isAudioMuted);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          color: isAudioMuted
                              ? Color(0xffD64467)
                              : Color(0xffffffff),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.06),
                                offset: Offset(0, 4)),
                          ]),
                      width: 72,
                      height: 72,
                      child: Icon(
                        isAudioMuted
                            ? Icons.mic_off_sharp
                            : Icons.mic_none_sharp,
                        color: isAudioMuted ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(flex: 16),
                  GestureDetector(
                    onTap: () {
                      _onVideoMutedChanged(!isVideoMuted);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          color: isVideoMuted
                              ? Color(0xffD64467)
                              : Color(0xffffffff),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.06),
                                offset: Offset(0, 4)),
                          ]),
                      width: 72,
                      height: 72,
                      child: Icon(
                        isVideoMuted
                            ? Icons.videocam_off_sharp
                            : Icons.videocam,
                        color: isVideoMuted ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(flex: 16),
                  GestureDetector(
                    onTap: () {
                      _joinMeeting(); // Join meet on tap
                    },
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                            color: Color(0xffAA66CC),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.06),
                                  offset: Offset(0, 4)),
                            ]),
                        width: 174,
                        height: 72,
                        child: Center(
                          child: Text(
                            "JOIN",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )),
                  ),
                  const Spacer(flex: 32),
                ],
              ),
              const Spacer(flex: 38),
            ],
          ),
        ),
      ),
    );
  }
// Can use this, to add one more button which makes the meet Audio only.
  // _onAudioOnlyChanged(bool? value) {
  //   setState(() {
  //     isAudioOnly = value!;
  //   });
  // }

  _onAudioMutedChanged(bool? value) {
    setState(() {
      isAudioMuted = value!;
    });
  }

  _onVideoMutedChanged(bool? value) {
    setState(() {
      isVideoMuted = value!;
    });
  }

// Defining Join meeting function
  _joinMeeting() async {
    // Using default serverUrl that is https://meet.jit.si/
    String? serverUrl =
        (serverText.text.trim().isEmpty ? null : serverText.text);

    try {
      // Enable or disable any feature flag here
      // If feature flag are not provided, default values will be used
      // Full list of feature flags (and defaults) available in the README
      FeatureFlag featureFlag = FeatureFlag();
      featureFlag.welcomePageEnabled = false;
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlag.callIntegrationEnabled = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlag.pipEnabled = false;
      }

      //uncomment to modify video resolution
      //featureFlag.resolution = FeatureFlagVideoResolution.MD_RESOLUTION;

      // Define meetings options here
      var options = JitsiMeetingOptions(room: roomText.text)
        ..serverURL = serverUrl
        ..subject = subjectText.text
        ..userDisplayName = nameText.text
        ..userEmail = emailText.text
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..featureFlags = featureFlag as Map<FeatureFlagEnum, bool>;

      debugPrint("JitsiMeetingOptions: $options");
      // Joining meet
      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(
            /*onConferenceWillJoin: 
            ({message = const {"" : ""}}) {
          debugPrint("${options.room} will join with message: $message");
        }, onConferenceJoined: ({message = const {"": ""}}) {
          debugPrint("${options.room} joined with message: $message");
        }, onConferenceTerminated: ({message = const {"": ""}}) {
          debugPrint("${options.room} terminated with message: $message");
        }, onPictureInPictureWillEnter: ({message = const {"": ""}}) {
          debugPrint("${options.room} entered PIP mode with message: $message");
        }, onPictureInPictureTerminated: ({message = const {"": ""}}) {
          debugPrint("${options.room} exited PIP mode with message: $message");
        }*/
            ),
        // by default, plugin default constraints are used
        //roomNameConstraints: new Map(), // to disable all constraints
        //roomNameConstraints: customContraints, // to use your own constraint(s)
      );
      // I added a 50 minutes time limit, you can remove it if you want.
      Future.delayed(const Duration(minutes: 50))
          .then((value) => JitsiMeet.closeMeeting());
    } catch (error) {
      debugPrint("error: $error");
    }
  }

// Define your own constraints
  static final Map<RoomNameConstraintType, RoomNameConstraint>
      customContraints = {
    RoomNameConstraintType.MAX_LENGTH: new RoomNameConstraint((value) {
      return value.trim().length <= 50;
    }, "Maximum room name length should be 30."),
    RoomNameConstraintType.FORBIDDEN_CHARS: new RoomNameConstraint((value) {
      return RegExp(r"[$€£]+", caseSensitive: false, multiLine: false)
              .hasMatch(value) ==
          false;
    }, "Currencies characters aren't allowed in room names."),
  };

  void _onConferenceWillJoin({message}) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined({message}) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated({message}) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  void _onPictureInPictureWillEnter({message}) {
    debugPrint(
        "_onPictureInPictureWillEnter broadcasted with message: $message");
  }

  void _onPictureInPictureTerminated({message}) {
    debugPrint(
        "_onPictureInPictureTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}
