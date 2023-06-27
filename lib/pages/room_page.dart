import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_pap/components/validated_text_field.dart';
import 'package:peerdart/peerdart.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Room extends StatefulWidget {
  final String conversationId;
  const Room({
    super.key,
    required this.conversationId,
  });

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  final TextEditingController _controller = TextEditingController();
  final Peer peer = Peer();
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  final currentUser = FirebaseAuth.instance.currentUser;
  bool inCall = false;
  String? peerId;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    peer.on("open").listen((id) {
      setState(() {
        peerId = peer.id;
      });
    });

    peer.on<MediaConnection>("call").listen((call) async {
      final mediaStream = await navigator.mediaDevices.getUserMedia({"video": true, "audio": true});

      call.answer(mediaStream);

      call.on("close").listen((event) {
        setState(() {
          inCall = false;
        });
      });

      call.on<MediaStream>("stream").listen((event) {
        _localRenderer.srcObject = mediaStream;
        _remoteRenderer.srcObject = event;

        setState(() {
          inCall = true;
        });
      });
    });
  }

  @override
  void dispose() {
    peer.dispose();
    _controller.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
    Navigator.pop(context);
  }

  void connect() async {
    final mediaStream = await navigator.mediaDevices.getUserMedia({"video": true, "audio": true});

    final conn = peer.call(_controller.text, mediaStream);

    conn.on("close").listen((event) {
      setState(() {
        inCall = false;
      });
    });

    conn.on<MediaStream>("stream").listen((event) {
      _remoteRenderer.srcObject = event;
      _localRenderer.srcObject = mediaStream;

      setState(() {
        inCall = true;
      });
    });
  }

  void send() {
    // conn.send('Hello!');
  }

  String getUsername() {
    try {
      FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).get().then((value) {
        return value['username'];
      });
    } catch (e) {
      print('error');
    }
    return currentUser!.email!.split('@')[0];
  }

  sendCallIdToFriend() async {
    try {
      await FirebaseFirestore.instance
          .collection('PrivateConversations')
          .doc(widget.conversationId)
          .collection('Messages')
          .add({
        'user': getUsername(),
        'message': "Junta-te à minha chamada com este ID: $peerId",
        'timeStamp': Timestamp.now(),
      });
    } catch (error) {
      print("An error occurred: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          leading: IconButton(
            icon: const Icon(Icons.call_end),
            tooltip: "Acabar a chamada",
            onPressed: dispose,
          ),
          actions: [_renderState()],
        ),
        body: Center(
          child: peerId != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            height: 600,
                            width: 600,
                            child: RTCVideoView(
                              _localRenderer,
                            ),
                          ),
                          if (inCall)
                            SizedBox(
                              height: 600,
                              width: 600,
                              child: RTCVideoView(
                                _remoteRenderer,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: Row(
                        children: [
                          Expanded(
                            child: ValidatedTextFormField(
                              controller: _controller,
                              hintText: 'Insira o ID da chamada para conectar-se',
                              obscureText: false,
                              maxLenght: 36,
                            ),
                          ),
                          IconButton(
                            onPressed: connect,
                            tooltip: 'Conectar  à chamada',
                            icon: const Icon(Icons.connect_without_contact),
                          ),
                          IconButton(
                            onPressed: sendCallIdToFriend,
                            tooltip: 'Mandar ID ao amigo',
                            icon: const Icon(Icons.message),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const Center(child: Text("A criar conecção....")),
        ));
  }

  Widget _renderState() {
    Color txtColor = inCall ? Colors.green : Colors.white;
    String txt = inCall ? "Conectado" : "À espera de conecções";
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
      ),
      height: 40,
      width: 240,
      child: Center(
        child: Text(
          txt,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: txtColor),
        ),
      ),
    );
  }
}
