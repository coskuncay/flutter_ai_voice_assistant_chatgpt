# Flutter AI Voice Assistant via ChatGPT

This project is a Flutter AI Voice Assistant via [ChatGPT](https://openai.com/blog/chatgpt) by [OpenAI](https://openai.com).  

This project requires a valid [session token](#sessiontoken) from ChatGPT to access its unofficial REST API , [speech_to_text](https://github.com/csdcorp/speech_to_text) and [flutter_tts](https://github.com/dlutton/flutter_tts)

*Sometimes slow to respond, mostly due to excessive use of ChatGPT
 
- [Demo](#demo)
- [Usage](#usage) 
- [SessionToken](#sessiontoken) 
- [Credit](#credit)
- [License](#license)

## Demo

<img src="https://user-images.githubusercontent.com/29631083/205933816-7e200521-7355-43e2-a41e-2a22c7b4c2c2.gif" width="300"/></a>
 
## Usage

```dart

import 'package:flutter_chatgpt_api/flutter_chatgpt_api.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

 @override
  void initState() {
    super.initState();
    _api = ChatGPTApi(sessionToken: SESSION_TOKEN);
    isLoading = false;
    _initSpeech();
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
```
## SessionToken 

To get a session token:

1. Go to https://chat.openai.com/chat and log in or sign up.
2. Open dev tools.
3. Open `Application` > `Cookies` (`Storage` > `Cookies` on FireFox)
   
 ![image](https://user-images.githubusercontent.com/38425102/205900045-185c2c41-b4ff-408c-9da6-bbb606ac39c6.png)
   
4. Create these files and add your session token to run the tests and example respectively:
- `lib/session_token.dart` 

Should look something like this:
```dart
const SESSION_TOKEN = 'my session token from https://chat.openai.com/chat';
```

## Credit

- Huge thanks to <a href="https://twitter.com/transitive_bs">Travis Fischer</a> for creating [Node.js ChatGPT API](https://github.com/transitive-bullshit/chatgpt-api) (unofficial)
- Speech to Text [speech_to_text](https://github.com/csdcorp/speech_to_text) by [Corner Software](https://github.com/csdcorp)
- Text to Speech [flutter_tts](https://github.com/dlutton/flutter_tts) by [Daniel Lutton](https://github.com/dlutton)
- Inspired by this [ChatGPT API Dart](https://github.com/MisterJimson/chatgpt_api_dart) by [Jason Rai](https://github.com/MisterJimson)

## License

[MIT](https://choosealicense.com/licenses/mit/) Copyright (c) 2022, [Emre Coşkunçay](https://github.com/coskuncay)

If you found this project interesting, please consider supporting my open source work by [sponsoring me](https://github.com/sponsors/coskuncay) or <a href="https://twitter.com/justecdev">following me on twitter <img src="https://storage.googleapis.com/saasify-assets/twitter-logo.svg" alt="twitter" height="24px" align="center"></a>