import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/screens/profile_screen.dart';
import 'package:jinx/screens/rooms_screen.dart';
import 'package:jinx/screens/usernotfound_screen.dart';
import '../models/user_model.dart';

class SearchScreen extends StatefulWidget {
  final UserModel user;


  SearchScreen(this.user);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController=  TextEditingController();
  Future <QuerySnapshot>? searchResultsFuture;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  List<String> blockedUsersByCurrentUser=[];
  List<String> usersBlockedCurrentUser=[];

  handleSearch(String query){
    Future <QuerySnapshot> users= FirebaseFirestore.instance.collection('users').where('name', isGreaterThanOrEqualTo:query.toLowerCase()).get();

    setState(() {
      searchResultsFuture = users;
    });
  }

  _getBlockedUsersByCurrentUser()async{
    QuerySnapshot snapshot= await FirebaseFirestore.instance.collection('block').doc(currentUserId).collection('userBlocked').get();
    snapshot.docs.forEach((doc) =>blockedUsersByCurrentUser.add(doc.id));
  }

  _getUsersBlockedCurrentUser()async{
    QuerySnapshot snapshot= await FirebaseFirestore.instance.collection('blockedUsers').doc(currentUserId).collection('blockedBy').get();
    snapshot.docs.forEach((doc) =>usersBlockedCurrentUser.add(doc.id));
  }

  buildSearchField(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor:Colors.transparent, //.withOpacity(0.8),
      title: Container(
       // padding: EdgeInsets.only(top: 10),
        height: 50,
        child: TextFormField(
          //textCapitalization: TextCapitalization.words,
          style: TextStyle(color: Colors.white),
          controller: searchController,
          decoration: InputDecoration(
           border: OutlineInputBorder(

                borderRadius: BorderRadius.all(
                    Radius.circular(30))),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white,),
                borderRadius: BorderRadius.all(
                    Radius.circular(30))),
            hintText: 'Search user',
            hintStyle: TextStyle(color: Colors.white),
            filled: true,
            prefixIcon: Icon(Icons.search,color: Colors.purple,),
            suffixIcon: IconButton(icon:Icon(Icons.clear,color: Colors.purple,), onPressed: (){
              searchController.clear();
            },),

          ),
          //onFieldSubmitted: handleSearch ,
           onChanged:(text){
            if(text.isNotEmpty){
              handleSearch(text);
            }
            },


        ),
      ),
    );

  }
  buildNoContent(){
    //orientation to fix image in landscape mode
    //final Orientation orientation=MediaQuery.of(context).orientation;
    return RoomScreen(widget.user);
  }

  buildSearchResults(){

    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
        if (!snapshot.hasData){
          return CircularProgressIndicator();
        }

        List<UserResult> searchResults = [];
        snapshot.data!.docs.forEach((doc) {

          ///function to avoid user to find themselfs or blocked user in search
          if (!blockedUsersByCurrentUser.contains(doc.id) && !usersBlockedCurrentUser.contains(doc.id)  && doc.id != currentUserId) {

            UserModel user = new UserModel.fromMap(doc);


            UserResult search = UserResult(user);

            searchResults.add(search);
          }
        });

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ListView(
            children: searchResults,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _getBlockedUsersByCurrentUser();
    _getUsersBlockedCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: buildSearchField(),
        body: searchResultsFuture == null ? buildNoContent(): buildSearchResults(),
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final UserModel user;

  UserResult(this.user);



  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(bottom:3),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.purple,
         // borderRadius: BorderRadius.circular(30)
        ),
        child: Column( children: [
          InkWell(
            onTap: () async{ await user != null? Navigator.push(context, MaterialPageRoute(builder:  (context) => ProfileScreen(user))):Navigator.push(context,
                MaterialPageRoute(builder:  (context) => UserNotFoundScreen()));},
            child: ListTile(
              leading: CircleAvatar(
                //CachedNetworkImageProvider store the image so it doesnt have load the image every time we need to load it
                child:CachedNetworkImage(
                  imageUrl: user.photo,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage('assets/defaultprofile.jpeg'), fit: BoxFit.cover),
                      )),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                //COLOr##################
                backgroundColor: Colors.grey,
              ),
              title: Text(user.name,style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold ),),
            ),
          ),

        ],),
      ),
    );
  }


}






