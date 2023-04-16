// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';
import 'main.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;

class CalendarScreen2 extends StatefulWidget {
  const CalendarScreen2({super.key, required this.lat, required this.lng});
  final double lat;
  final double lng;

  @override
  State<CalendarScreen2> createState() => _CalendarScreen2State();
}

class _CalendarScreen2State extends State<CalendarScreen2> {
  var slcDay = DateTime.now();
  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  var calFormat = CalendarFormat.month;
  List prayerName = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
  List prayerTime2 = ["00:00", "00:00", "00:00", "00:00", "00:00"];
  List prayerTimesO = [
    "00:00",
    "00:00",
    "00:00",
    "00:00",
    "00:00",
    "00:00",
    "00:00"
  ];
  double TimeSize = 21;
  void getPrayerTimes({bool refresh = false, required DateTime date}) async {
    String ti = await FlutterNativeTimezone.getLocalTimezone();
    final prefs = await SharedPreferences.getInstance();
    var loc = await prefs.getStringList("location");
    final timezone = await tz.getLocation(ti);
    String timezone21 = tzmap.latLngToTimezoneString(widget.lat, widget.lng);
    final timezone2 = await tz.getLocation(timezone21);
    print("$timezone2 $timezone21");
    print("$ti $timezone");

    bool format24 = prefs.getBool("24format")!;
    if (format24 == false) {
      setState(() {
        TimeSize = 17;
        print("changed size");
      });
    }

    Coordinates coordinates = Coordinates(widget.lat, widget.lng);
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
    print("midnight is $midnightTime");
    String fajrTime2 = format(tz.TZDateTime.from(prayerTimes.fajr!, timezone2),
        format24: format24);
    String sunriseTime2 = format(
        tz.TZDateTime.from(prayerTimes.sunrise!, timezone2),
        format24: format24);
    String dhuhrTime2 = format(
        tz.TZDateTime.from(prayerTimes.dhuhr!, timezone2),
        format24: format24);
    String asrTime2 = format(tz.TZDateTime.from(prayerTimes.asr!, timezone2),
        format24: format24);
    String maghribTime2 = format(
        tz.TZDateTime.from(prayerTimes.maghrib!, timezone2),
        format24: format24);
    String ishaTime2 = format(tz.TZDateTime.from(prayerTimes.isha!, timezone2),
        format24: format24);
    String fajrTimeafter2 = format(
        tz.TZDateTime.from(prayerTimes.fajrafter!, timezone2),
        format24: format24);
    String midnightTime2 = format(
        tz.TZDateTime.from(sunnahTimes.middleOfTheNight, timezone2),
        format24: format24);

    setState(() {
      prayerTime2 = [
        fajrTime,
        dhuhrTime,
        asrTime,
        maghribTime,
        ishaTime,
      ];
      prayerTimesO = [
        fajrTime2,
        dhuhrTime2,
        asrTime2,
        maghribTime2,
        ishaTime2,
      ];
    });
    print(prayerTime2);
    print(prayerTimesO);
  }

  @override
  void initState() {
    // TODO: implement initState
    getPrayerTimes(date: slcDay);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            TableCalendar(
              focusedDay: slcDay,
              selectedDayPredicate: (day) {
                return isSameDay(slcDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  slcDay = selectedDay; // update `_focusedDay` here as well
                });
                getPrayerTimes(date: slcDay);
              },
              firstDay: slcDay.add(Duration(days: -365)),
              lastDay: slcDay.add(
                Duration(days: 365),
              ),
              calendarFormat: calFormat,
              onFormatChanged: (format) {
                setState(() {
                  calFormat = format;
                });
              },
            ),
            Divider(
              color: Colors.grey,
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('EEEE d\'${_getDaySuffix(slcDay.day)}\' MMMM y')
                      .format(slcDay),
                      style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text("Prayer"),
                  ),
                  Visibility(
                    visible: prayerTime2[0] == prayerTimesO[0] ? false : true,
                    child: Expanded(
                      child: Text(
                        "Foreign",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Local",
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () async {},
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          color: Colors.transparent,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    prayerName[index],
                                    style: TextStyle(
                                      color: Color(0xFF505FB6),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: prayerTime2[0] == prayerTimesO[0]
                                    ? false
                                    : true,
                                child: Expanded(
                                  child: Text(
                                    prayerTimesO[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color(0xFF505FB6), fontSize: 20),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  prayerTime2[index],
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Color(0xFF505FB6), fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      index != 4
                          ? SizedBox(
                              height: 20,
                            )
                          : SizedBox(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
