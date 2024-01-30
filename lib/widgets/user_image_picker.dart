import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jinx/models/user_model.dart';

class EditProfileImagePicker extends StatefulWidget {
  EditProfileImagePicker(this.imagePickFn, this.user);

  final void Function(File pickedImage) imagePickFn;
  final UserModel user;

  @override
  _EditProfileImagePickerState createState() => _EditProfileImagePickerState();
}

class _EditProfileImagePickerState extends State<EditProfileImagePicker> {
  File? _pickedImage;

  //File? _galleryIcon;

  _pickFromGallery(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery, /*imageQuality: 50,maxWidth: 150*/
    );
    final pickedImageFile = File(pickedImage!.path);

    setState(() {
      _pickedImage = File(pickedImageFile.path);
    });
    widget.imagePickFn(pickedImageFile);
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
                    backgroundImage: NetworkImage(widget.user.photo),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    primary:  Color(0xfff1efe5), // foreground
                  ),

                  onPressed: () {
                    _pickFromGallery(ImageSource.gallery);
                  },
                  icon: Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            )
          ],
        )
      ],
    );
  }
}
