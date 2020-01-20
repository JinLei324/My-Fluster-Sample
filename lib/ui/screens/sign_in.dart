import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:groomlyfe/global/data.dart';
import 'package:groomlyfe/util/state_widget.dart';
import 'package:groomlyfe/util/auth.dart';
import 'package:groomlyfe/util/validator.dart';
import 'package:groomlyfe/ui/widgets/loading.dart';

class SignInScreen extends StatefulWidget {
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();

  bool _autoValidate = false;
  bool _loadingVisible = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user_videos = [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60.0,
          child: ClipOval(
            child: Image.asset(
              'assets/images/default.png',
              fit: BoxFit.cover,
              width: 120.0,
              height: 120.0,
            ),
          )),
    );

    final email = TextFormField(
      style: new TextStyle(color: Colors.black,fontFamily: 'arial',fontWeight: FontWeight.bold),
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: _email,
      validator: Validator.validateEmail,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.email,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Email',
        hintStyle: TextStyle(color: Colors.white),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),borderSide: new BorderSide(color: Colors.white,width: 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),borderSide: new BorderSide(color: Colors.white,width: 2)),

      ),
    );

    final password = TextFormField(
      style: new TextStyle(color: Colors.black,fontFamily: 'arial',fontWeight: FontWeight.bold),
      autofocus: false,
      obscureText: true,
      controller: _password,
      validator: Validator.validatePassword,
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.white),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.lock,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),borderSide: new BorderSide(color: Colors.white)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),borderSide: new BorderSide(color: Colors.white,width: 2)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          _emailLogin(
              email: _email.text, password: _password.text, context: context);
        },
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text('SIGN IN', style: TextStyle(color: Colors.white)),
      ),
    );

    final socialLoginButton = Container(
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          _googleLogin();
        },
        padding: EdgeInsets.all(12),
        color: Colors.red[400],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Icon(FontAwesomeIcons.google,color: Colors.yellow,size: 16,),
            Text('SIGN IN WITH GOOGLE', style: TextStyle(color: Colors.white)),
          ],
        )
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.yellowAccent),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/forgot-password');
      },
    );

    final signUpLabel = FlatButton(
      child: Text(
        'Create an Account',
        style: TextStyle(color: Colors.yellow),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(opacity: 1,child:AspectRatio(aspectRatio: background_video_controller.value.aspectRatio, child: VideoPlayer(background_video_controller),),),
                Opacity(
                  opacity:0.3,
                  child: Container(
                    color: Colors.lightBlueAccent,
                  ),
                ),
              ],
            ),
            LoadingScreen(
                child: Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(height: 20,),
                            email,
                            SizedBox(height: 24.0),
                            password,
                            SizedBox(height: 12.0),
                            loginButton,
                            socialLoginButton,
                            forgotLabel,
                            signUpLabel
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                inAsyncCall: _loadingVisible),
          ],
        ),
    );
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void _emailLogin(
      {String email, String password, BuildContext context}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();
        //need await so it has chance to go through error if found.
        await StateWidget.of(context).logInUser(email, password);
        await Navigator.pushNamed(context, '/home');
      } catch (e) {
        _changeLoadingVisible();
        print("Sign In Error: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
          title: "Sign In Error",
          message: exception,
          duration: Duration(seconds: 5),
        )..show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }
  void _googleLogin() async{
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();
        await StateWidget.of(context).googleSignIn();
        print("----------------------------------------------");
        await Navigator.pushNamed(context, '/home');
      }catch(e){
        _changeLoadingVisible();
        print("Sign In Error: $e");
        Flushbar(
          title: "Sign In Error",
          message: "$e",
          duration: Duration(seconds: 5),
        )..show(context);
      }
  }
}
