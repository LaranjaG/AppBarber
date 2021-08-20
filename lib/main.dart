import 'package:app_barbearia/telas/Map.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'Rotas.dart';

final ThemeData temaPadrao = ThemeData(
  primaryColor: Colors.grey,

  iconTheme: IconThemeData(
    color: Colors.white,
  ),
  primaryIconTheme: IconThemeData(
      color: Colors.white, //Controla a cor primaria do icone (Icone do nav)
      size: 20),
  hintColor: Colors.white,

  popupMenuTheme: PopupMenuThemeData(color: Colors.black),
  cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
      primaryColor: Colors.black, barBackgroundColor: Colors.red),
  dataTableTheme:
      DataTableThemeData(dividerThickness: 20, decoration: BoxDecoration()),
  primaryTextTheme: TextTheme(
    headline6: TextStyle(color: Colors.white),
    subtitle1: TextStyle(color: Colors.white),
    bodyText1: TextStyle(
      color: Colors.red,
    ),
    bodyText2: TextStyle(
      color: Colors.white,
    ),
  ),

  // ignore: deprecated_member_use
  cursorColor: Colors.grey,
  accentColor: Colors.blue[900], //Mudar a cor do Swite

  focusColor: Colors.white,

  textTheme: TextTheme(
    bodyText1: TextStyle(color: Colors.white),
    bodyText2: TextStyle(color: Colors.white, fontSize: 16),
    headline1: TextStyle(color: Colors.white),
    headline2: TextStyle(color: Colors.white),
    headline4: TextStyle(color: Colors.white),
    headline3: TextStyle(color: Colors.white),
    headline5: TextStyle(color: Colors.white),
    headline6: TextStyle(color: Colors.white),
    caption: TextStyle(color: Colors.white),
    button: TextStyle(color: Colors.white),
    overline: TextStyle(color: Colors.white),
    // ignore: deprecated_member_use
    // title: TextStyle(color: Colors.white),
  ),
  disabledColor: Colors.white,
  scaffoldBackgroundColor: Colors.grey[800],
  fontFamily: 'times',

  appBarTheme: AppBarTheme(
      color: Color.fromRGBO(14, 14, 14, 0.85),
      centerTitle: true,

      // shadowColor: Colors.blue,
      elevation: 5 //Quantidade de sombra
      //iconTheme:
      ),

  secondaryHeaderColor: Colors.white,

  canvasColor: Color.fromRGBO(14, 14, 14, 0.85),

  inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
      hintStyle: TextStyle(color: Colors.white),
      labelStyle: TextStyle(color: Colors.white, decorationColor: Colors.white),
      counterStyle: TextStyle(fontSize: 20, color: Colors.white),
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))),

  cardTheme: CardTheme(
    color: Color(0xff002a31),
    shadowColor: Color.fromRGBO(50, 20, 10, 0.9),
    elevation: 7,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.5),
    ),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    OneSignal.shared.init('48d60f4d-5efe-4fcb-be06-651820135204');

    // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.none);
    //
    // OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
    //
    // });
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        // const Locale('en', ''), // English, no country code
        const Locale('pt', ''), // Hebrew, no country code
        // const Locale.fromSubtags(languageCode: 'zh')
      ],

      title: "Barbers",
      initialRoute: "/",
      // home: Map(),
      //Rota inicial, a primeira pagina que se irá abrir para o usuário
      onGenerateRoute: Rotas.gerarRotas,
      theme: temaPadrao,
      debugShowCheckedModeBanner: false,
    );
  }
}
