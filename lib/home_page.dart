import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:persona/feature_box.dart';
import 'package:persona/openai_service.dart';
import 'package:persona/pallete.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();

  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  String lastWords = '';
  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  Future<void> SystemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });

    @override
    void dispose() {
      super.dispose();
      speechToText.stop();
      flutterTts.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ziv"),
        centerTitle: true,
        leading: const Icon(Icons.menu),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Pallete.assistantCircleColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                height: 123,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/virtualAssistant.png'),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: generatedImageUrl == null ? true : false,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              margin:
                  const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
              decoration: BoxDecoration(
                  border: Border.all(color: Pallete.borderColor),
                  borderRadius: BorderRadius.circular(20).copyWith(
                    topLeft: Radius.zero,
                  )),
              child: Text(
                generatedContent == null ? 'Good Morning, What task can i do for you?' : generatedContent!,
                style: TextStyle(
                  color: Pallete.mainFontColor,
                  fontSize: generatedContent == null ? 23 : 18,
                ),
              ),
            ),
          ),
          if(generatedImageUrl != null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!)),
            ),
          Visibility(
            visible: generatedContent == null && generatedImageUrl == null ? true : false,
            child: Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(
                top: 10,
                left: 22,
              ),
              child: const Text(
                "Here are a few features. What would you like to try?",
                style: TextStyle(
                  color: Pallete.mainFontColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Visibility(
            visible: generatedContent == null && generatedImageUrl == null ? true : false,
            child: Column(
              children: const [
                FeatureBox(
                  color: Pallete.firstSuggestionBoxColor,
                  headerText: "ChatGPT",
                  descriptionText:
                      "A Smarter way to stay updated and Organized with ChatGPT",
                ),
                SizedBox(
                  height: 2,
                ),
                FeatureBox(
                  color: Pallete.secondSuggestionBoxColor,
                  headerText: "Dall-E",
                  descriptionText:
                      "Get Inspired and stay creative with your personal assistant powered by Dall-E",
                ),
                SizedBox(
                  height: 2,
                ),
                FeatureBox(
                  color: Pallete.thirdSuggestionBoxColor,
                  headerText: "Smart Voice Assistant",
                  descriptionText:
                      "Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT",
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            final speech = await openAIService.isArtPromptApi(lastWords);
            if(speech.contains('https')) {
              generatedImageUrl = speech;
              generatedContent = null;
              setState(() {

              });
            }
            else {
              generatedImageUrl = null;
              generatedContent = speech;
              setState(() {

              });
              await SystemSpeak(speech);
            }

            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        backgroundColor: Pallete.firstSuggestionBoxColor,
        child: const Icon(Icons.mic),
      ),
    );
  }
}
