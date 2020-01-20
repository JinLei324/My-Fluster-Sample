import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:groomlyfe/models/state.dart';
import 'package:groomlyfe/models/user.dart';
import 'package:groomlyfe/models/settings.dart';
import 'package:groomlyfe/util/auth.dart';
import 'package:date_format/date_format.dart';

class StateWidget extends StatefulWidget {
  final StateModel state;
  final Widget child;

  StateWidget({
    @required this.child,
    this.state,
  });

  // Returns data of the nearest widget _StateDataWidget
  // in the widget tree.
  static _StateWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
            as _StateDataWidget)
        .data;
  }

  @override
  _StateWidgetState createState() => new _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  StateModel state;
  bool google_sign_in_check = false;
  //GoogleSignInAccount googleAccount;
  //final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();
    google_sign_in_check = false;
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = new StateModel(isLoading: true);
      initUser();
    }
  }

  Future<Null> initUser() async {
    //print('...initUser...');
    FirebaseUser firebaseUserAuth = await Auth.getCurrentFirebaseUser();
    User user;
    if(google_sign_in_check){
      String _create_at = formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy]);
      user = User(userId: firebaseUserAuth.uid,
          photoUrl: firebaseUserAuth.photoUrl,
          email: firebaseUserAuth.email,
          firstName: firebaseUserAuth.displayName.split(" ")[0],
          lastName: firebaseUserAuth.displayName.split(" ").length>1?firebaseUserAuth.displayName.split(" ")[1]:"",
          create_at: _create_at);
    }else{
      user = await Auth.getUserLocal();
    }
    Settings settings = await Auth.getSettingsLocal();
    setState(() {
      state.isLoading = false;
      state.firebaseUserAuth = firebaseUserAuth;
      state.user = user;
      state.settings = settings;
    });
    google_sign_in_check = false;
  }

  Future<void> logOutUser() async {
    await Auth.signOut();
    FirebaseUser firebaseUserAuth = await Auth.getCurrentFirebaseUser();
    setState(() {
      state.user = null;
      state.settings = null;
      state.firebaseUserAuth = firebaseUserAuth;
    });
  }

  Future<void> logInUser(email, password) async {
    String userId = await Auth.signIn(email, password);
    User user = await Auth.getUserFirestore(userId);

    Settings settings = await Auth.getSettingsFirestore(userId);
    print(settings.settingsId);
    await Auth.storeSettingsLocal(settings);
    await initUser();
  }

  Future<void> googleSignIn()async{
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    print("+++++++++++++++++++++0+++++++++++++++++++++");

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    print("+++++++++++++++++++++1+++++++++++++++++++++");

    final AuthCredential credential =await GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    print("+++++++++++++++++++++2+++++++++++++++++++++");
    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++$user");
    print("+++++++++++++++++++++3+++++++++++++++++++++");

    print(user.displayName);
    var user_new = new User(userId: user.uid,
      photoUrl: user.photoUrl,
      email: user.email,
      firstName: user.displayName.split(" ")[0],
      lastName: user.displayName.split(" ").length>1?user.displayName.split(" ")[1]:"",);


    await Auth.addUserSettingsDB(user_new);
    print("+++++++++++++++++++++4+++++++++++++++++++++");

    await Auth.getSettingsFirestore(user_new.userId).then((Settings settings)async{
      print(settings.settingsId);
      await Auth.storeSettingsLocal(settings);
      google_sign_in_check = true;
      await initUser();
    });
    print("+++++++++++++++++++++5+++++++++++++++++++++");

  }


  @override
  Widget build(BuildContext context) {
    return new _StateDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class _StateDataWidget extends InheritedWidget {
  final _StateWidgetState data;

  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  // Rebuild the widgets that inherit from this widget
  // on every rebuild of _StateDataWidget:
  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}
