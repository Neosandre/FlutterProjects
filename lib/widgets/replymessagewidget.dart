import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/message_model.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';

class ReplyMessageWidget extends StatelessWidget {
  final MessageModel message;
  final VoidCallback onCancelReply;

  const ReplyMessageWidget(
    this.message,
    this.onCancelReply,
  );

  @override
  Widget build(BuildContext context) {

    return IntrinsicHeight(
      child: Row(

        children: [
          Container(
            color: Colors.purple,
            width: 4,
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: buildReplyMessage(),
          )
        ],
      ),
    );
  }

  Widget buildReplyMessage() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(message.name,
                      style: TextStyle(
                        //fontSize: ,
                        fontWeight: FontWeight.bold,
                      ))),
              if (onCancelReply != null)
                GestureDetector(
                  child: Icon(
                    Icons.clear_rounded,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onTap: onCancelReply,
                )
            ],
          ),
          Row(
            children: [
              message.message == 'image'
                  ? Container(
                      height: 50,
                      width: 50,
                      child: Image.network(message.file.toString()),
                    )
                  : Expanded(
                      child: Text(
                      message.message,
                      style: TextStyle(color: Colors.purple),
                    )),
              message.message == 'audio message...'
                  ? Icon(
                      Icons.mic,
                      size: 12,
                      color: Colors.purple,
                    )
                  : Container(),
              message.message == 'audio message...'
                  ? Text(
                      '${message.duration}',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    )
                  : Container(),
              SizedBox(
                width: 3,
              )
            ],
          ),
          Text(
            '${message.replyMessageTime}',
            style: TextStyle(color: Colors.black, fontSize: 8),
          ),
        ],
      );
}

class DisplayReplyMessageWidget extends StatelessWidget {
  final MessageModel message;

  const DisplayReplyMessageWidget(
    this.message,
  );

  ///URL lancher
  Future<void> _launchUrl(String url, context) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceWebView: true,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'can\'t launch Link up, please make sure it contains https//:...'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {

    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            color: Colors.blue,
            width: 4,
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: buildReplyMessage(context),
          )
        ],
      ),
    );
  }

  Widget buildReplyMessage(context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                message.replyMessageName
                    .toString(), style: TextStyle(fontSize:12,color: Colors.purple,fontWeight: FontWeight.bold, ),
              )),
            ],
          ),
          isURL(message.replyMessage.toString())
              ? Container(
                  width: 250,
                  child: InkWell(
                    onTap: () =>
                        _launchUrl(message.replyMessage.toString(), context),
                    child: Text(
                      message.replyMessage.toString(),
                      style: TextStyle(
                          color: Colors.blue[700],
                          decoration: TextDecoration.underline),
                      textAlign: TextAlign.start,
                      //overflow:TextOverflow.ellipsis,
                    ),
                  ),
                )
              : message.replyMessage.toString() == 'audio message...'
                  ? Row(
                      children: [
                        Icon(
                          Icons.mic,
                          size: 12,
                          color: Colors.purple,
                        ),
                        Text(
                          '${message.replyMessageDuration.toString()}',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    )
                  : message.replyMessage.toString() == 'image'
                      ? Container(
                          height: 50,
                          width: 50,
                          child: ClipRRect(
                              child:CachedNetworkImage(
                            imageUrl: message.replyMessagefile.toString(),) ),
                        )
                      : Text(
                          message.replyMessage.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 2),
            child: Text(
              '${message.displayMessageTime}',
              style: TextStyle(color: Colors.black, fontSize: 8),
            ),
          ),
        ],
      );
}
