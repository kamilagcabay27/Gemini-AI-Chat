import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class EditImage extends StatefulWidget {
  const EditImage({super.key, required this.image});
  final CroppedFile image;

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double w = size.width;
    double h = size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm The Image'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: InteractiveViewer(
                child: Image(
                  image: FileImage(
                    File(
                      widget.image.path,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: h * 0.04,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade300,
                fixedSize: Size(w * 0.9, h * 0.05),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontFamily: 'Hanken',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
