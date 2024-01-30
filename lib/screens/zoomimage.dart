import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ZoomImage extends StatelessWidget {
  String boardImage;

  ZoomImage(this.boardImage);

 // @override
 // State<ZoomImage> createState() => _ZoomImageState();
//}

//class _ZoomImageState extends State<ZoomImage> {
  PhotoViewController _controller = PhotoViewController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Image viewer'),
          backgroundColor: Colors.transparent,
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context)),
        ),
        body: Center(
          child: PhotoView(

            controller: _controller,
            imageProvider: CachedNetworkImageProvider(boardImage),
          ),
        ));
  }
}
