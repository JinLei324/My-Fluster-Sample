import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:groomlyfe/models/user.dart';
import 'package:groomlyfe/util/auth.dart';
import 'package:groomlyfe/util/validator.dart';
import 'package:groomlyfe/util/image_picker_handler.dart';
import 'package:groomlyfe/util/storage.dart';
import 'package:groomlyfe/ui/widgets/loading.dart';
import 'package:date_format/date_format.dart';


class SignUpScreen extends StatefulWidget {
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin,ImagePickerListener {

  File _image;
  AnimationController _animationController;
  ImagePickerHandler imagePicker;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = new TextEditingController();
  final TextEditingController _lastName = new TextEditingController();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();

  bool _autoValidate = false;
  bool _loadingVisible = false;
  @override
  void initState() {
    _animationController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    imagePicker=new ImagePickerHandler(this,_animationController);
    imagePicker.init();
    super.initState();
  }

  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60.0,
          child: ClipOval(
            child: FlatButton(onPressed: (){
              imagePicker.showDialog(context);
            },
              child:_image==null? Container(child: Icon(Icons.photo_camera,size: 80,color: Colors.blueGrey, ),padding: EdgeInsets.all(20),):new Container(
                height: 120.0,
                width: 120.0,
                decoration: new BoxDecoration(
                  color: const Color(0xff7c94b6),
                ),
                child: Image.file(_image, fit: BoxFit.cover,height: 100,),
              ),
              padding: EdgeInsets.all(0),
              highlightColor: Colors.white,
              color: Colors.grey,

            )
          )),
    );

    final firstName = TextFormField(
      autofocus: false,
      textCapitalization: TextCapitalization.words,
      controller: _firstName,
      validator: Validator.validateName,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.person,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'First Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final lastName = TextFormField(
      autofocus: false,
      textCapitalization: TextCapitalization.words,
      controller: _lastName,
      validator: Validator.validateName,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.person,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Last Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final email = TextFormField(
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
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: _password,
      validator: Validator.validatePassword,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.lock,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          String _create_at = formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy]);
          _emailSignUp(
              firstName: _firstName.text,
              lastName: _lastName.text,
              email: _email.text,
              password: _password.text,
              create_at: _create_at,
              context: context);
        },
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text('SIGN UP', style: TextStyle(color: Colors.white)),
      ),
    );

    final signInLabel = FlatButton(
      child: Text(
        'Have an Account? Sign In.',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/signin');
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Opacity(opacity: 0.2,child:Image.asset('assets/images/back-login.png',fit: BoxFit.fill,),
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
                          SizedBox(height: 30,),
                          logo,
                          SizedBox(height: 40.0),
                          firstName,
                          SizedBox(height: 24.0),
                          lastName,
                          SizedBox(height: 24.0),
                          email,
                          SizedBox(height: 24.0),
                          password,
                          SizedBox(height: 12.0),
                          signUpButton,
                          signInLabel
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

  void _emailSignUp(
      {String firstName,
      String lastName,
      String email,
      String password,
      String create_at,
      BuildContext context}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();
        //need await so it has chance to go through error if found.
        await Auth.signUp(email, password).then((uID){
          Storage().uploadFile(_image, uID).then((photourl){
            Auth.addUserSettingsDB(new User(
              userId: uID,
              photoUrl: photourl,
              email: email,
              firstName: firstName,
              lastName: lastName,
              create_at: create_at
            ));
          });
        });
        //now automatically login user too
        //await StateWidget.of(context).logInUser(email, password);
        await Navigator.pushNamed(context, '/signin');
      } catch (e) {
        _changeLoadingVisible();
        print("Sign Up Error: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
          title: "Sign Up Error",
          message: exception,
          duration: Duration(seconds: 5),
        )..show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }
  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
    });
  }
}
