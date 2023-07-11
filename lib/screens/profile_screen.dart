import '../barrel/export.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userData = {};
  int postLength = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post length
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      if (userSnap.data() != null) {
        setState(() {
          userData = userSnap.data()!;
          postLength = postSnap.docs.length;
          followers = userSnap.data()!['followers'].length;
          following = userSnap.data()!['following'].length;
          isFollowing = userSnap
              .data()!['followers']
              .contains(FirebaseAuth.instance.currentUser!.uid);
        });
      }
      print(userData);
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          userData['username'] ?? '',
        ),
        centerTitle: false,
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: Colors.grey.shade900,
              ),
            ),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'signOut') {
                  AuthMethods().signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                } else if (value == 'settings') {
                  // Handle settings here
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'signOut',
                    child: Text(
                      'Sign Out',
                      style: TextStyle(),
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: userData['photoUrl'] != null
                          ? NetworkImage(userData['photoUrl']!)
                          : null,
                      radius: 40,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStatColumn(postLength, 'posts'),
                              buildStatColumn(followers, 'followers'),
                              buildStatColumn(following, 'following'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FirebaseAuth.instance.currentUser!.uid ==
                                      widget.uid
                                  ? FollowButton(
                                      backgroundColor: mobileBackgroundColor,
                                      borderColor: Colors.grey,
                                      text: 'Edit Profile',
                                      textColor: primaryColor,
                                      function: () {},
                                    )
                                  : isFollowing
                                      ? FollowButton(
                                          backgroundColor: Colors.white,
                                          borderColor: Colors.grey,
                                          text: 'Unfollow',
                                          textColor: Colors.black,
                                          function: () {
                                            Stream<String> followStream =
                                                FireStoreMethods().followUser(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              userData['uid'],
                                            );

                                            followStream
                                                .listen((String result) {
                                              if (result == 'success') {
                                                setState(() {
                                                  isFollowing = false;
                                                  followers--;
                                                });
                                              } else {
                                                showSnackBar(
                                                    'Error unfollowing user',
                                                    context);
                                              }
                                            });
                                          },
                                        )
                                      : FollowButton(
                                          backgroundColor: Colors.blue,
                                          borderColor: Colors.blue,
                                          text: 'Follow',
                                          textColor: Colors.white,
                                          function: () {
                                            Stream<String> followStream =
                                                FireStoreMethods().followUser(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              userData['uid'],
                                            );

                                            followStream
                                                .listen((String result) {
                                              if (result == 'success') {
                                                setState(() {
                                                  isFollowing = true;
                                                  followers++;
                                                });
                                              } else {
                                                showSnackBar(
                                                    'Error following user',
                                                    context);
                                              }
                                            });
                                          },
                                        ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Text(
                    userData['username'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 1,
                  ),
                  child: Text(
                    userData['bio'] ?? '',
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('posts')
                .where('uid', isEqualTo: widget.uid)
                .get(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                showSnackBar(snapshot.error.toString(), context);
              }

              return GridView.builder(
                shrinkWrap: true,
                itemCount: (snapshot.data! as dynamic).docs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 1.5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  DocumentSnapshot snap =
                      (snapshot.data! as dynamic).docs[index];

                  return Container(
                    child: Image(
                      image: NetworkImage(
                        snap['postUrl'],
                      ),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Column buildStatColumn(int num, String label) {
    String text = num == 1 ? label.substring(0, label.length - 1) : label;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            top: 4,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
