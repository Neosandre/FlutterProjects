class MessageModel {
  String name;
  String userId;

  //String messageId;
  String message;

  //DateTime createdAt;
  //String photo;
  String? replyMessage;
  String replyMessageTime;
  String? replyMessageDuration;
  String? duration;
  String? displayMessageTime;
  String? replyMessageName;
  String photo;
  String file;
  String type;
  String? replyMessagefile;
  String? messageId;

  //String status;

  MessageModel({
    required this.name,
    required this.userId,
    //required this.messageId,
    required this.message,
    //required this.createdAt,
    //required this.status
    //required this.photo,
    required this.replyMessage,
    required this.replyMessageTime,
    required this.replyMessageDuration,
    required this.duration,
    required this.displayMessageTime,
    required this.replyMessageName,
    required this.photo,
    required this.file,
    required this.type,
    required this.replyMessagefile,
    required this.messageId,
  });

  factory MessageModel.fromMap(dynamic documentSnapshot) {
    return MessageModel(
        name: documentSnapshot['name'],
        userId: documentSnapshot['useId'],
        //messageId: documentSnapshot['messageId'],
        message: documentSnapshot['message'],
        //createdAt: documentSnapshot['createdAt'] ,
        //photo: documentSnapshot['photo'],
        replyMessage: documentSnapshot['replyMessage'],
        // MessageModel.fromMap(documentSnapshot['replyMessage']),
        //status: documentSnapshot['status']
        replyMessageTime: documentSnapshot['replyMessageTime'],
        replyMessageDuration: documentSnapshot['replyMessageDuration'],
        duration: documentSnapshot['duration'],
        displayMessageTime: documentSnapshot['displayMessageTime'],
        replyMessageName: documentSnapshot['replyMessageName'],
        photo: documentSnapshot['photo'],
        file: documentSnapshot['file'],
        type: documentSnapshot['type'],
        replyMessagefile: documentSnapshot['replyMessagefile'],
        messageId: documentSnapshot['messageId']);
  }

  Map<String, dynamic> toMap(MessageModel message) => {
        'name': message.name,
        'userId': message.userId,
        //'messageId':message.messageId,
        'message': message.message,
        //'createdAt':message.createdAt,
        //'photo':message.photo,
        'replyMessage':
            message.replyMessage == null ? null : replyMessage.toString(),
        'replyMessageTime': message.replyMessageTime,
        'replyMessageDuration': message.replyMessageDuration,
        'duration': message.duration,
        'displayMessageTime': message.displayMessageTime,
        "type": message.type,
        'replyMessagefile': message.replyMessagefile,
        'messageId': message.messageId
        //'status':user.status
      };
}
