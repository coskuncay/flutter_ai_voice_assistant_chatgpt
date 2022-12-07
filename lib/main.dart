import 'package:flutter/material.dart';
import 'package:flutter_ai_voice_assistant/session_token.dart';
import 'package:flutter_chatgpt_api/flutter_chatgpt_api.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter AI Voice Assistant via ChatGPT @coskuncay',
      home: ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

const backgroundColor = Color(0xff343541);
const botBackgroundColor = Color(0xff444654);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SpeechToText _speechToText = SpeechToText();
  bool speechEnabled = false;
  final FlutterTts tts = FlutterTts();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late ChatGPTApi _api;

  String? _parentMessageId;
  String? _conversationId;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    _api = ChatGPTApi(sessionToken: SESSION_TOKEN);
    isLoading = false;
    _initSpeech();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Flutter AI Voice Assistant via ChatGPT @coskuncay',
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: botBackgroundColor,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildList(),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : FloatingActionButton(
                      backgroundColor: botBackgroundColor,
                      onPressed: () {
                        tts.stop();
                        _startListening();
                      },
                      child: Icon(
                        _speechToText.isNotListening
                            ? Icons.mic_off
                            : Icons.mic,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _initSpeech() async {
    speechEnabled = await _speechToText.initialize();
    _speechToText.systemLocale().then(
          (value) => tts.setLanguage(value!.localeId),
        );
    tts.setSpeechRate(0.6);
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(
      () {
        if (result.finalResult) {
          _buildSubmit(result.recognizedWords);
        }
      },
    );
  }

  _buildSubmit(String prompt) async {
    setState(
      () {
        _messages.add(
          ChatMessage(
            text: prompt,
            chatMessageType: ChatMessageType.user,
          ),
        );
        isLoading = true;
      },
    );
    var input = prompt;
    Future.delayed(const Duration(milliseconds: 50)).then((_) => _scrollDown());
    var newMessage = await _api.sendMessage(
      input,
      conversationId: _conversationId,
      parentMessageId: _parentMessageId,
    );
    setState(() {
      _conversationId = newMessage.conversationId;
      _parentMessageId = newMessage.messageId;
      isLoading = false;
      _messages.add(
        ChatMessage(
          text: newMessage.message,
          chatMessageType: ChatMessageType.bot,
        ),
      );
      tts.speak(newMessage.message);
    });
    Future.delayed(const Duration(milliseconds: 50)).then((_) => _scrollDown());
  }

  ListView _buildList() {
    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      },
      controller: _scrollController,
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot
          ? botBackgroundColor
          : backgroundColor,
      child: Row(
        children: [
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: const Color.fromRGBO(16, 163, 127, 1),
                    child: Image.asset(
                      'assets/bot.png',
                      color: Colors.white,
                      scale: 1.5,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: const CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/pp.png',
                    ),
                  ),
                ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
