import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);

  final void Function(File pickedImage) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  //File? _galleryIcon;

  _pickFromGallery(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery, /*imageQuality: 50,maxWidth: 150*/
    );
    if(pickedImage != null ){
      final pickedImageFile = File(pickedImage!.path);
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
      widget.imagePickFn(pickedImageFile);
    }



  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            _pickedImage != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    backgroundImage: FileImage(_pickedImage!),
                  )
                : CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    //backgroundImage:  NetworkImage() ,
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    primary: Color(0xfff1efe5), // foreground
                  ),

                  onPressed: () {
                    _pickFromGallery(ImageSource.gallery);
                  },
                  icon: Icon(Icons.image),
                  label: Text('Gallery'),
                )
              ],
            )
          ],
        )
      ],
    );
  }
}
