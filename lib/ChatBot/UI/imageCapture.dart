import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageCaptureWidget extends StatefulWidget {
  final List<File> capturedImages;  // List to store the captured Images

  ImageCaptureWidget({required this.capturedImages});

  @override
  _ImageCaptureWidgetState createState() => _ImageCaptureWidgetState();
}

class _ImageCaptureWidgetState extends State<ImageCaptureWidget> {
  final ImagePicker _picker = ImagePicker(); // Instance of image picker
  // Function to capture images
  Future<void> _captureImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        widget.capturedImages.add(File(pickedFile.path)); // Add the new image to the list
      });
    }
  }

  // Function to delete an image
  void _deleteImage(int index) {
    setState(() {
      widget.capturedImages.removeAt(index); // Remove the selected image from the list
    });
  }

  // Function to preview an image in fullscreen
  void _previewImage(File image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          children: [
            Expanded(
              child: Image.file(image),
            ),
            ElevatedButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
            onPressed: _captureImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50, // Light blue background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50), // Rounded corners
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Add padding
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      Icons.camera_alt,
                      size: 30,
                      color: Colors.blue.shade900
                  ),
                  const SizedBox(width: 8), // Spacing between icon and text
                  Text(
                    'Click To Capture Images',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ]
            )
        ),
        if (widget.capturedImages.isNotEmpty)
          const SizedBox(height: 8),
        Row(
          children: [
            if (widget.capturedImages.isNotEmpty)
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.capturedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          GestureDetector(
                            onTap: () => _previewImage(widget.capturedImages[index]), // Preview image in fullscreen
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              child: Image.file(
                                widget.capturedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteImage(index), // Delete the selected image
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
