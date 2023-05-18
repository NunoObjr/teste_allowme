import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String _allowMeResult = "";
  bool _enableBiometry = false;
  bool _workingOnSdkAsync = false;

  static const platform = const MethodChannel("br.com.samples.allowme/sdk");

  Future<void> _didReceiveBiometry(MethodCall call) async {
    final String result = call.arguments;

    switch (call.method) {
      case "didReceiveBiometry":
        if (result != null) {
          setState(() {
            _allowMeResult = result;
          });
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _permissionRequest();
    WidgetsBinding.instance.addObserver(this);
  }

  void _permissionRequest() async {
    var permissions = [
      Permission.camera,
      Permission.phone,
      Permission.location
    ];

    for (var permission in permissions) {
      await permission.request();
    }

    var cameraGranted = await Permission.camera.status;

    setState(() {
      _enableBiometry = cameraGranted.isGranted;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _disableProgressBar();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _biometry() async {
    String biometry = "No Context yet";

    try {
      biometry = await platform.invokeMethod('biometry');
    } on PlatformException catch (e) {
      biometry = "Failed to get Context '${e.message}'.";
    }

    _setAllowMeResult(biometry);
    _disableProgressBar();
  }

  Future<void> _collect() async {
    String collect = "No Context yet";

    try {
      collect = await platform.invokeMethod('collect');
    } on PlatformException catch (e) {
      collect = "Failed to get Context '${e.message}'.";
    }

    _setAllowMeResult(collect);
    _disableProgressBar();
  }

  Future<void> _startSDK() async {
    String startResult = "Not started yet";

    try {
      startResult = await platform.invokeMethod('start');
    } on PlatformException catch (e) {
      startResult = "Failed to start SDK '${e.message}'.";
    }

    _setAllowMeResult(startResult);
    _disableProgressBar();
  }

  Future<void> _setupSDK() async {
    String setupResult = "No uuid yet";

    try {
      setupResult = await platform.invokeMethod('setup');
    } on PlatformException catch (e) {
      setupResult = "Failed to init onboarding '${e.message}'.";
    }

    _setAllowMeResult(setupResult);
    _disableProgressBar();
  }

  Future<void> _addPerson() async {
    String addPersonResult = "No result yet";

    try {
      await platform.invokeMethod('addPerson');
      addPersonResult = "Add Person with success";
    } on PlatformException catch (e) {
      addPersonResult = "Failed to add Person '${e.message}'.";
    }

    _setAllowMeResult(addPersonResult);
    _disableProgressBar();
  }

  void _setAllowMeResult(String result) {
    setState(() {
      _allowMeResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final methodChannel = MethodChannel("br.com.samples.allowme/sdk");
    methodChannel.setMethodCallHandler(this._didReceiveBiometry);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _createOptionWidget(_setupSDK, "Setup SDK"),
              _createOptionWidget(_startSDK, "Start SDK"),
              _createOptionWidget(_collect, "Collect"),
              _createOptionWidget(_addPerson, "Add Person"),
              _createOptionWidget(_biometry, "Biometry",
                  enabled: _enableBiometry),
              Text(
                '$_allowMeResult',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              _showProgress()
            ],
          ),
        ));
  }

  Widget _createOptionWidget(Function onPressFn, String text,
      {bool enabled = true}) {
    return Container(
      width: 250.0,
      color: enabled ? Colors.blue : Color.fromARGB(100, 192, 192, 192),
      padding: EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: enabled
            ? () {
                onPressFn.call();
                _enableProgressBar();
                _setAllowMeResult("");
              }
            : null,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _enableProgressBar() {
    setState(() {
      _workingOnSdkAsync = true;
    });
  }

  void _disableProgressBar() {
    setState(() {
      _workingOnSdkAsync = false;
    });
  }

  Widget _showProgress() {
    return Visibility(
      child: CircularProgressIndicator(value: null),
      visible: _workingOnSdkAsync,
    );
  }
}
