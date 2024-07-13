import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gemini_ai_app/components/cropped_image.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  XFile? image;
  bool changeTheme = false;

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiAI = ChatUser(
    id: "1",
    firstName: "GeminiAI",
    profileImage:
        "https://logowik.com/content/uploads/images/google-ai-gemini91216.logowik.com.webp",
  );

  void selectImage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Bu resmi açıklar mısın?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          ),
        ],
      );
      _sendMessage(chatMessage);
    }
  }

  void selectCropImage(bool pickImageFromGallery) async {
    final picker = ImagePicker();

    if (pickImageFromGallery == true) {
      image = await picker.pickImage(source: ImageSource.gallery);
    } else {
      image = await picker.pickImage(source: ImageSource.camera);
    }

    if (image != null) {
      final croppedImage = await cropImages(image!);

      if (croppedImage != null) {
        ChatMessage chatMessage = ChatMessage(
          user: currentUser,
          createdAt: DateTime.now(),
          text: "Bu resmi açıklar mısın?",
          medias: [
            ChatMedia(
              url: croppedImage.path,
              fileName: "",
              type: MediaType.image,
            ),
          ],
        );
        _sendMessage(chatMessage);
      }
    }
  }

  Future<CroppedFile?> cropImages(XFile image) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Colors.deepOrange,
          toolbarTitle: 'Edit Image',
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio7x5,
          ],
        ),
      ],
    );

    return croppedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Gemini Chat",
        ),
        leading: IconButton(
          icon: Icon(Get.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          onPressed: () {
            if (Get.isDarkMode) {
              setState(() {});
              Get.changeTheme(ThemeData.light());
            } else {
              Get.changeTheme(ThemeData.dark());
            }
          },
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(trailing: [
        IconButton(
          onPressed: selectImage,
          icon: const Icon(Icons.image),
        ),
        IconButton(
          onPressed: () {
            selectCropImage(false);
          },
          icon: const Icon(
            Icons.camera,
            color: Colors.blue,
          ),
        ),
      ]),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages ?? [],
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }
      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiAI) {
          lastMessage = messages.removeAt(0);

          String response = event.content?.parts?.fold(
                  "",
                  (previousValue, current) =>
                      "$previousValue ${current.text}") ??
              "";

          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "",
                  (previousValue, current) =>
                      "$previousValue ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
              user: geminiAI, createdAt: DateTime.now(), text: response);
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
