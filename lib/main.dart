// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:ios_prayer/calendar_screen2.dart';
import 'calendar_screen.dart';
import 'city_screen.dart';
import 'compass_screen.dart';
import 'dua_text.dart';
import 'missed_screen.dart';
import 'settings_screen.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api/notification_api.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'compass_screen2.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'city_screen.dart';

String format(date, {bool format24 = true}) {
  if (format24 == true) {
    return DateFormat.Hm().format(date);
  } else {
    return DateFormat.jm().format(date);
  }

  """
  var format;
  getFormat().then((value) {
    bool euFormat = value;
    if (euFormat == true) {
      format = DateFormat.Hm().format(date);
    } else {
      format = DateFormat.jm().format(date);
    }
  });
  print(format);
  return format;
  """;
}

final calcMethods = {
  "Muslim World League": CalculationMethod.MuslimWorldLeague(),
  "Egyptian": CalculationMethod.Egyptian(),
  "Umm al Qura": CalculationMethod.UmmAlQura(),
  "Dubai": CalculationMethod.Dubai(),
  "Qatar": CalculationMethod.Qatar(),
  "Kuwait": CalculationMethod.Kuwait(),
  "Singapore": CalculationMethod.Singapore(),
  "Turkey": CalculationMethod.Turkey(),
  "Tehran": CalculationMethod.Tehran(),
  "North America": CalculationMethod.NorthAmerica(),
};

final madhab = {"shafi": Madhab.Shafi, "hanafi": Madhab.Hanafi};
List<DateTime> getDataDay(addDay, lat, long, ti, mad, method) {
  final timezone = tz.getLocation(ti);
  DateTime date = new tz.TZDateTime.from(
      DateTime.now().add(Duration(days: addDay)), timezone);

  Coordinates coordinates =
      new Coordinates(double.parse(lat), double.parse(long));
  CalculationParameters params = calcMethods[method];
  params.madhab = madhab[mad];
  PrayerTimes prayerTimes = new PrayerTimes(coordinates, date, params);

  DateTime one = tz.TZDateTime.from(prayerTimes.fajr!, timezone);
  DateTime two = tz.TZDateTime.from(prayerTimes.sunrise!, timezone);
  DateTime three = tz.TZDateTime.from(prayerTimes.dhuhr!, timezone);
  DateTime four = tz.TZDateTime.from(prayerTimes.asr!, timezone);
  DateTime five = tz.TZDateTime.from(prayerTimes.maghrib!, timezone);
  DateTime six = tz.TZDateTime.from(prayerTimes.isha!, timezone);

  return [
    one,
    two,
    three,
    four,
    five,
    six,
  ];
}

Future createNoti(lat, long, ti, mad, method) async {
  final prefs = await SharedPreferences.getInstance();
  bool format24 = prefs.getBool("24format")!;
  for (int i = 2; i < 8; i++) {
    var dataOfPrayer = getDataDay(i - 1, lat, long, ti, mad, method);
    for (int n = 1; n < 6; n++) {
      if (n == 1) {
        await NotificationApi.showScheduledNotification(
          id: (i - 1) * 5 + n,
          title: "Fajr Time",
          body: format(dataOfPrayer[0], format24: format24),
          scheduledDate: dataOfPrayer[0],
        );
      } else if (n == 2) {
        await NotificationApi.showScheduledNotification(
          id: (i - 1) * 5 + n,
          title: "Dhuhr Time",
          body: format(dataOfPrayer[2], format24: format24),
          scheduledDate: dataOfPrayer[2],
        );
      } else if (n == 3) {
        await NotificationApi.showScheduledNotification(
          id: (i - 1) * 5 + n,
          title: "Asr Time",
          body: format(dataOfPrayer[3], format24: format24),
          scheduledDate: dataOfPrayer[3],
        );
      } else if (n == 4) {
        await NotificationApi.showScheduledNotification(
          id: (i - 1) * 5 + n,
          title: "Maghrib Time",
          body: format(dataOfPrayer[4], format24: format24),
          scheduledDate: dataOfPrayer[4],
        );
      } else if (n == 5) {
        await NotificationApi.showScheduledNotification(
          id: (i - 1) * 5 + n,
          title: "Isha Time",
          body: format(dataOfPrayer[5], format24: format24),
          scheduledDate: dataOfPrayer[5],
        );
      }
    }
  }
}

Future createAllNoti() async {
  tz.initializeTimeZones();
  String ti = await FlutterNativeTimezone.getLocalTimezone();
  final prefs = await SharedPreferences.getInstance();
  var lat = prefs.getStringList("location")![0];
  var long = prefs.getStringList("location")![1];
  var mad = prefs.getString("madhab");
  var method = prefs.getString("method");
  var today = getDataDay(0, lat, long, ti, mad, method);
  bool format24 = prefs.getBool("24format")!;

  DateTime fajr1 = today[0];
  DateTime dhuhr1 = today[2];
  DateTime asr1 = today[3];
  DateTime maghrib1 = today[4];
  DateTime isha1 = today[5];
  var tom = getDataDay(1, lat, long, ti, mad, method);
  String next = getNext(lat, long, ti, mad, method);
  int nowEpoch = DateTime.now().millisecondsSinceEpoch;
  DateTime fajr2 = tom[0];
  int? epoch = prefs.getInt("nextEpoch");
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.cancelAll();

  if (next == "fajr") {
    await NotificationApi.showScheduledNotification(
      id: 1,
      title: "Fajr Time",
      body: format(fajr1, format24: format24),
      scheduledDate: fajr1,
    );
    prefs.setString("nextNoti", "fajr");
    prefs.setInt("nextEpoch", fajr1.millisecondsSinceEpoch);
    await NotificationApi.showScheduledNotification(
      id: 2,
      title: "Dhuhr Time",
      body: format(dhuhr1, format24: format24),
      scheduledDate: dhuhr1,
    );
    await NotificationApi.showScheduledNotification(
      id: 3,
      title: "Asr Time",
      body: format(asr1, format24: format24),
      scheduledDate: asr1,
    );
    await NotificationApi.showScheduledNotification(
      id: 4,
      title: "Maghrib Time",
      body: format(maghrib1, format24: format24),
      scheduledDate: maghrib1,
    );
    await NotificationApi.showScheduledNotification(
      id: 5,
      title: "Isha Time",
      body: format(isha1, format24: format24),
      scheduledDate: isha1,
    );
  } else if (next == "dhuhr") {
    await NotificationApi.showScheduledNotification(
      id: 2,
      title: "Dhuhr Time",
      body: format(dhuhr1, format24: format24),
      scheduledDate: dhuhr1,
    );
    prefs.setString("nextNoti", "dhuhr");
    prefs.setInt("nextEpoch", dhuhr1.millisecondsSinceEpoch);

    await NotificationApi.showScheduledNotification(
      id: 3,
      title: "Asr Time",
      body: format(asr1, format24: format24),
      scheduledDate: asr1,
    );
    await NotificationApi.showScheduledNotification(
      id: 4,
      title: "Maghrib Time",
      body: format(maghrib1, format24: format24),
      scheduledDate: maghrib1,
    );
    await NotificationApi.showScheduledNotification(
      id: 5,
      title: "Isha Time",
      body: format(isha1, format24: format24),
      scheduledDate: isha1,
    );
  } else if (next == "asr") {
    print("asr runing");
    await NotificationApi.showScheduledNotification(
      id: 3,
      title: "Asr Time",
      body: format(asr1, format24: format24),
      scheduledDate: asr1,
    );
    print(asr1.millisecondsSinceEpoch.toString() + " This is epoch ");

    prefs.setString("nextNoti", "asr");
    prefs.setInt("nextEpoch", asr1.millisecondsSinceEpoch);
    await NotificationApi.showScheduledNotification(
      id: 4,
      title: "Maghrib Time",
      body: format(maghrib1, format24: format24),
      scheduledDate: maghrib1,
    );
    await NotificationApi.showScheduledNotification(
      id: 5,
      title: "Isha Time",
      body: format(isha1, format24: format24),
      scheduledDate: isha1,
    );
  } else if (next == "maghrib") {
    print("maghrib ran");
    await NotificationApi.showScheduledNotification(
        id: 4,
        title: "Maghrib Time",
        body: format(maghrib1, format24: format24),
        scheduledDate: maghrib1,
        payload: maghrib1.toString());
    prefs.setString("nextNoti", "maghrib");
    prefs.setInt("nextEpoch", maghrib1.millisecondsSinceEpoch);
    await NotificationApi.showScheduledNotification(
      id: 5,
      title: "Isha Time",
      body: format(isha1, format24: format24),
      scheduledDate: isha1,
    );
  } else if (next == "isha") {
    await NotificationApi.showScheduledNotification(
      id: 5,
      title: "Isha Time",
      body: format(isha1, format24: format24),
      scheduledDate: isha1,
    );
    prefs.setString("nextNoti", "isha");
    prefs.setInt("nextEpoch", isha1.millisecondsSinceEpoch);
  } else if (next == "fajrafter") {
    prefs.setString("nextNoti", "fajrafter");
    prefs.setInt("nextEpoch", fajr2.millisecondsSinceEpoch);
  }
  await createNoti(lat, long, ti, mad, method);
  var pendingNotificationRequests2 =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  for (int i = 0; i < pendingNotificationRequests2.length; i++) {
    print(pendingNotificationRequests2[i].body.toString() + "dsjhf");
  }
}

String getNext(lat, long, ti, mad, method) {
  final timezone = tz.getLocation(ti);
  DateTime date = new tz.TZDateTime.from(DateTime.now(), timezone);

  Coordinates coordinates =
      new Coordinates(double.parse(lat), double.parse(long));
  CalculationParameters params = calcMethods[method];
  params.madhab = madhab[mad];
  PrayerTimes prayerTimes = new PrayerTimes(coordinates, date, params);
  String next =
      prayerTimes.nextPrayer(date: DateTime.now().add(Duration(hours: 0)));
  return next;
}

void initTimeZone() {
  tz.initializeTimeZones();
}

late Position position2;
Future determinePosition2() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  print(permission.toString() + " This is location perm");
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  position2 = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList("location",
      [position2.latitude.toString(), position2.longitude.toString()]);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationApi.init();

  String ti = await FlutterNativeTimezone.getLocalTimezone();
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("24format") == false) {
    prefs.setBool("24format", true);
  }
  if (prefs.containsKey("myCities") == false) {
    prefs.setStringList("myCities", []);
  }
  if (prefs.containsKey('location') == false) {
    prefs.setStringList('location', <String>["46.180370", "6.095370"]);
    await Geolocator.requestPermission();

    LocationPermission permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.deniedForever) {
      print("denied");
    } else {
      await determinePosition2();
    }

    //await determinePosition2();
  }
  if (prefs.containsKey('method') == false) {
    prefs.setString("method", "Tehran");
    prefs.setString("madhab", "shafi");
  }
  if (prefs.containsKey("fajrMissed") == false) {
    await prefs.setInt("fajrMissed", 0);
    await prefs.setInt("dhuhrMissed", 0);
    await prefs.setInt("asrMissed", 0);
    await prefs.setInt("maghribMissed", 0);
    await prefs.setInt("ishaMissed", 0);
  }

  int nowEpoch = DateTime.now().millisecondsSinceEpoch;
  if (prefs.containsKey("nextNoti") == false) {
    await createAllNoti();
  }

  runApp(MyApp());

  var pendingNotificationRequests2 =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  for (int i = 0; i < pendingNotificationRequests2.length; i++) {
    //print(pendingNotificationRequests2[i].body.toString() + "dsfdsf");
  }

  print(prefs.getString("nextNoti"));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String name = "Loading";
  List prayerNames = [
    "Fajr",
    "Sunrise",
    "Dhuhr",
    "Asr",
    "Maghrib",
    "Isha",
    "Midnight"
  ];
  List prayerTimes2 = [
    "00:00",
    "00:00",
    "00:00",
    "00:00",
    "00:00",
    "00:00",
    "00:00"
  ];
  late FixedExtentScrollController scrollController;
  List<Color> firstGrad = [
    Color(0xff100e2a), //fajr
    Color(0xffeb6344),
    Color.fromARGB(255, 131, 208, 236), //sunrise
    Color(0xff4ca1dc),
    //asr
    Color(0xff8a327d),
    Color(0xff6f53a5),
    Color.fromARGB(255, 24, 0, 71), //isha
  ];
  List secondGrad = [
    Color(0xff2e2855), //fajr
    Color(0xffeaab94), //sunrise
    Color(0xffade0f2),
    Color.fromARGB(255, 137, 191, 230),
    //asr
    Color(0xffc630a4),
    Color(0xffaa9cc7),
    Color.fromARGB(255, 141, 116, 192), //isha
  ];

  List mosqueFront = [
    Colors.black, //fajr
    Color.fromARGB(255, 24, 19, 18), //sunrise
    Color.fromARGB(255, 23, 33, 54),
    Color.fromARGB(255, 23, 33, 54), //asr
    Color.fromARGB(255, 21, 23, 41),
    Color.fromARGB(255, 21, 23, 41),
    Color.fromARGB(255, 21, 23, 41), //isha
  ];
  late int nextPrayer;
  late String nextPrayerTime;
  late Position position;
  late double lng;
  late double lat;
  Future _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      position;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("location",
        [position.latitude.toString(), position.longitude.toString()]);
  }

  void getPrayerTimes({bool refresh = false}) async {
    String ti = await FlutterNativeTimezone.getLocalTimezone();
    final prefs = await SharedPreferences.getInstance();
    var loc = await prefs.getStringList("location");
    final timezone = tz.getLocation(ti);
    bool format24 = prefs.getBool("24format")!;
    DateTime date = tz.TZDateTime.from(DateTime.now(), timezone);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        double.parse(loc![0]),
        double.parse(loc![1]),
      );
      setState(() {
        name = placemarks.first.locality.toString();
      });
    } catch (e) {
      setState(() {
        name = "No internet";
        nextPrayer = 0;
      });
    }
    setState(() {
      lat = double.parse(loc![0]);
      lng = double.parse(loc![1]);
    });
    Coordinates coordinates =
        Coordinates(double.parse(loc![0]), double.parse(loc[1]));
    var mad = prefs.getString("madhab");
    var method = prefs.getString("method");
    CalculationParameters params = calcMethods[method];
    params.madhab = madhab[mad];
    PrayerTimes prayerTimes = PrayerTimes(coordinates, date, params);
    SunnahTimes sunnahTimes = SunnahTimes(prayerTimes);

    String fajrTime = format(tz.TZDateTime.from(prayerTimes.fajr!, timezone),
        format24: format24);
    String sunriseTime = format(
        tz.TZDateTime.from(prayerTimes.sunrise!, timezone),
        format24: format24);
    String dhuhrTime = format(tz.TZDateTime.from(prayerTimes.dhuhr!, timezone),
        format24: format24);
    String asrTime = format(tz.TZDateTime.from(prayerTimes.asr!, timezone),
        format24: format24);
    String maghribTime = format(
        tz.TZDateTime.from(prayerTimes.maghrib!, timezone),
        format24: format24);
    String ishaTime = format(tz.TZDateTime.from(prayerTimes.isha!, timezone),
        format24: format24);
    String fajrTimeafter = format(
        tz.TZDateTime.from(prayerTimes.fajrafter!, timezone),
        format24: format24);
    String midnightTime = format(
        tz.TZDateTime.from(sunnahTimes.middleOfTheNight, timezone),
        format24: format24);

    setState(() {
      String next = prayerTimes.nextPrayer();

      if (refresh == false) {
        nextPrayer = next == "fajrafter"
            ? 0
            : next == "fajr"
                ? 0
                : next == "dhuhr"
                    ? 2
                    : next == "asr"
                        ? 3
                        : next == "maghrib"
                            ? 4
                            : next == "isha"
                                ? 5
                                : 0;
        scrollController = FixedExtentScrollController(initialItem: nextPrayer);
      }
      if (refresh == true) {
        print("THIS IS RUNNING");
        nextPrayer = next == "fajrafter"
            ? 0
            : next == "fajr"
                ? 0
                : next == "dhuhr"
                    ? 2
                    : next == "asr"
                        ? 3
                        : next == "maghrib"
                            ? 4
                            : next == "isha"
                                ? 5
                                : 0;
        scrollController.animateToItem(nextPrayer,
            duration: Duration(milliseconds: 10), curve: Curves.easeIn);
        print(scrollController.selectedItem);
      }

      nextPrayerTime = next == "fajrafter"
          ? fajrTimeafter
          : next == "fajr"
              ? fajrTime
              : next == "dhuhr"
                  ? dhuhrTime
                  : next == "asr"
                      ? asrTime
                      : next == "maghrib"
                          ? maghribTime
                          : next == "isha"
                              ? ishaTime
                              : fajrTime;
      prayerTimes2 = [
        fajrTime,
        sunriseTime,
        dhuhrTime,
        asrTime,
        maghribTime,
        ishaTime,
        midnightTime,
      ];
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state.toString() + " This is the state");
    if (AppLifecycleState.resumed == state) {
      getPrayerTimes(refresh: true);
      createAllNoti();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getPrayerTimes();
    createAllNoti();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  AppBar appbar = AppBar(
    centerTitle: true,
    leading: Container(
      child: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {},
      ),
    ),
    backgroundColor: Colors.transparent,
    title: Text("Next prayer time"),
    actions: [
      Container(
        child: IconButton(
          icon: Icon(Icons.refresh_rounded),
          onPressed: () {},
        ),
      ),
    ],
  );
  var controller123 = SidebarXController(selectedIndex: 0, extended: true);
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _key,
        drawer: SidebarX(
          theme: const SidebarXTheme(
              textStyle: TextStyle(color: Colors.white),
              iconTheme: IconThemeData(
                color: Colors.white,
                size: 20,
              ),
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 45, 45, 45))),
          extendedTheme: const SidebarXTheme(
            width: 200,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 45, 45, 45),
            ),
          ),
          controller: controller123,
          items: [
            SidebarXItem(icon: Icons.home, label: 'Home'),
            SidebarXItem(
              icon: Icons.explore,
              label: 'Qibla',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompassScreen2()),
                );
                setState(() {
                  controller123 =
                      SidebarXController(selectedIndex: 0, extended: false);
                });
              },
            ),
            SidebarXItem(
              icon: FontAwesomeIcons.personPraying,
              label: 'Missed Prayers',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MissedPrayerScreen()),
                );
                setState(() {
                  controller123 =
                      SidebarXController(selectedIndex: 0, extended: false);
                });
              },
            ),
            SidebarXItem(
              icon: FontAwesomeIcons.earthAfrica,
              label: 'City',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CityScreen()),
                );
                setState(() {
                  controller123 =
                      SidebarXController(selectedIndex: 0, extended: false);
                });
              },
            ),
            SidebarXItem(
              icon: Icons.calendar_month,
              label: 'Calendar',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CalendarScreen2(
                            lat: lat,
                            lng: lng,
                          )),
                );
                setState(() {
                  controller123 =
                      SidebarXController(selectedIndex: 0, extended: false);
                });
              },
            ),

            SidebarXItem(
              icon: Icons.settings,
              label: "Settings",
              onTap: () async {
                Navigator.pop(context);
                setState(() {
                  controller123 =
                      SidebarXController(selectedIndex: 0, extended: false);
                });
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
                getPrayerTimes(refresh: true);
                createAllNoti();
              },
            ),

            /// SidebarXItem(
            ///   icon: Icons.menu_book,
            ///   label: "Dua",
            ///   onTap: () {
            ///     Navigator.pop(context);
            ///     Navigator.push(
            ///       context,
            ///       MaterialPageRoute(builder: (context) => DuaText()),
            ///     );
            ///     setState(() {
            ///       controller123 =
            ///           SidebarXController(selectedIndex: 0, extended: false);
            ///     });
            ///   },
            /// ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                firstGrad[nextPrayer],
                secondGrad[nextPrayer],
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              AppBar(
                centerTitle: true,
                leading: Container(
                  child: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      print(height);
                      _key.currentState!.openDrawer();
                    },
                  ),
                ),
                backgroundColor: Colors.transparent,
                title: Text("Next prayer time"),
                actions: [
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.refresh_rounded),
                      onPressed: () async {
                        await _determinePosition();
                        getPrayerTimes(refresh: true);
                        await createAllNoti();
                      },
                    ),
                  ),
                ],
              ),
              SvgPicture.asset(
                'assets/images/mosques_background.svg',
                alignment: Alignment.bottomCenter,
                width: (MediaQuery.of(context).size.width),
                height: MediaQuery.of(context).size.height,
                color: Color.fromARGB(255, 29, 25, 52),
              ),
              Container(
                  child: (() {
                if (nextPrayer == 0 ||
                    nextPrayer == 4 ||
                    nextPrayer == 5 ||
                    nextPrayer == 6) {
                  return Stack(
                    children: [
                      Align(
                        child: Image.asset("assets/images/moon.png"),
                        alignment: Alignment.center,
                      ),
                      Align(
                        child: SizedBox(
                          child: Image.asset("assets/images/moon_b.png"),
                          height: 133,
                        ),
                        alignment: Alignment.center,
                      ),
                    ],
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: SvgPicture.asset(
                      'assets/images/assr_sun_detail.svg',
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width),
                      height: MediaQuery.of(context).size.height,
                    ),
                  );
                }
              }())),
              SvgPicture.asset(
                'assets/images/mosques_foreground2.svg',
                alignment: Alignment.bottomCenter,
                width: (MediaQuery.of(context).size.width),
                height: MediaQuery.of(context).size.height,
                color: mosqueFront[nextPrayer],
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: height < 670
                            ? appbar.preferredSize.height + 25
                            : appbar.preferredSize.height + 50,
                      ),
                      Text(
                        "$name",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        nextPrayerTime,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 65,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 216,
                  color: Colors.transparent,
                  child: CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 0.75,
                    diameterRatio: 3,
                    useMagnifier: true,
                    itemExtent: 50,
                    scrollController: scrollController,
                    // This is called when selected item is changed.
                    onSelectedItemChanged: (int selectedItem) async {
                      setState(() {
                        nextPrayer = selectedItem;
                      });

                      print(nextPrayer);
                    },
                    children:
                        List<Widget>.generate(prayerNames.length, (int index) {
                      return Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              prayerNames[index],
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              prayerTimes2[index],
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
