class UserCardDetails {
  String name;
  String id;
  String photo;
  String roomId;

  UserCardDetails({
    required this.name,
    required this.id,
    required this.photo,
    required this.roomId,
  });

  factory UserCardDetails.fromMap(dynamic documentSnapshot) {
    return UserCardDetails(
        name: documentSnapshot['name'],
        id: documentSnapshot['userId'],
        photo: documentSnapshot['photo'],
        roomId: documentSnapshot['roomId']);
  }

  Map<String, dynamic> toMap(UserCardDetails user) => {
        'name': user.name,
        'userId': user.id,
        'photo': user.photo,
        'roomId': user.roomId
      };
}
