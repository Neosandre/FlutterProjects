

class PostModel{
  String name;
  String userId;
  String photo;
  //String messageId;
  bool anonymous;
  //Timestamp time;
  String? postImage;
  String type;
  String postId;
  String? createdBy;
  String? option1;
  String? option2;
  String? option3;
  String text;
  bool poll;
  double option1P;
  double option2P;
  double option3P;
  //Map<String, int> userWhoVoted;

  PostModel({
    required this.name,
    required this.userId,
    required this.photo,
    required this.anonymous,
    //required this.time,
    required this.postImage,
    required this.type,
    required this.postId,
    required this.createdBy,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.text,
    required this.poll,
    required this.option1P,
    required this.option2P,
    required this.option3P,
    //required this.userWhoVoted

});

  factory PostModel.fromMap(dynamic doc){
    return PostModel(
        name: doc['name'],
        userId: doc['userId'],
        photo: doc['photo'],
        anonymous: doc['anonymous'],
        //time: doc['time'],
        postImage: doc['postImage'],
        type: doc['type'],
        postId: doc['postId'],
        createdBy: doc['createdBy'],
        option1: doc['option1'],
        option2: doc['option2'],
        option3: doc['option3'],
        text: doc['text'],
        poll: doc['poll'],
        option1P: doc["option1P"],
        option2P: doc["option2P"],
        option3P: doc["option3P"],
      //userWhoVoted: doc["userWhoVoted"]

    );
  }
  Map<String, dynamic> toMap(PostModel post) => {
    'name':post.name,
    'userId':post.userId,
    'photo':post.photo,
    'anonymous':post.anonymous,
    //'time':post.time,
    'postImage':post.postImage,
    'type':post.type,
    'postId':post.postId,
    'createdBy':post.createdBy,
    'option1':post.option1,
    'option2':post.option2,
    'option3':post.option3,
    'text':post.text,
    'poll':post.poll,
    'option1P':post.option1,
    'option2P':post.option2,
    'option3P':post.option3,
    //'userWhoVoted':post.userWhoVoted
  };

}