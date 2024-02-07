import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_05_gold_price_list/model/Gold.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIÁ VÀNG SJC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff1D7DE8),
          title: const Center(
            child: Text(
              'GIÁ VÀNG SJC',
              style: TextStyle(
                  fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: const GoldListView(),
      )),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GoldListView extends StatefulWidget {
  const GoldListView({super.key});

  @override
  State<StatefulWidget> createState() {
    return GoldListViewState();
  }
}

class GoldListViewState extends State<GoldListView> {
  final goldData = <Gold>[];
  final goldStreamController = StreamController<List<Gold>>();
  late Stream goldStream;

  void getGoldInfo() async {
    final client = Client();
    const jscUrl = 'https://sjc.com.vn/giavang/textContent.php';
    final response = await client.get(Uri.parse(jscUrl));
    final document = parse(response.body);
    final trs = document.querySelectorAll('tr');
    for (final tr in trs) {
      final tds = tr.children;
      try {
        goldData.add(Gold(tds[0].text, tds[1].text, tds[2].text));
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }

    goldStreamController.sink.add(goldData);
  }

  @override
  void initState() {
    super.initState();
    goldStream = goldStreamController.stream;
    getGoldInfo();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: goldStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Gold> goldList = snapshot.data;
            return Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                height: 510,
                color: const Color(0xff003150),
                child: ListView.separated(
                  itemCount: goldList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(children: [
                      Expanded(
                          flex: 4,
                          child:
                              // ignore: sized_box_for_whitespace
                              Container(
                                  height: 50,
                                  child: Center(
                                      child: Text(goldList[index].typeGold,
                                          style: TextStyle(
                                              fontSize: (index == 0) ? 14 : 13,
                                              color: const Color(0xffFFF200),
                                              fontWeight: (index == 0)
                                                  ? FontWeight.bold
                                                  : FontWeight.normal))))),
                      Expanded(
                          flex: 1,
                          // ignore: sized_box_for_whitespace
                          child: Container(
                              color: (index == 0)
                                  ? const Color(0xff003150)
                                  : const Color(0xff416C7E),
                              height: 50,
                              child: Center(
                                  child: Text(goldList[index].intGold,
                                      style: TextStyle(
                                          fontSize: (index == 0) ? 14 : 10,
                                          color: (index == 0)
                                              ? const Color(0xffFFF200)
                                              : Colors.white,
                                          fontWeight: (index == 0)
                                              ? FontWeight.bold
                                              : FontWeight.normal))))),
                      Expanded(
                          flex: 1,
                          // ignore: sized_box_for_whitespace
                          child: Container(
                              color: (index == 0)
                                  ? const Color(0xff003150)
                                  : const Color(0xff416C7E),
                              height: 50,
                              child: Center(
                                  child: Text(goldList[index].outGold,
                                      style: TextStyle(
                                          fontSize: (index == 0) ? 14 : 10,
                                          color: (index == 0)
                                              ? const Color(0xffFFF200)
                                              : Colors.white,
                                          fontWeight: (index == 0)
                                              ? FontWeight.bold
                                              : FontWeight.normal))))),
                    ]);
                  },
                  separatorBuilder: (context, index) {
                    return Container(
                      height: 1,
                      color: const Color(0xffcc9900),
                    );
                  },
                ));
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  @override
  void dispose() {
    super.dispose();
    goldStreamController.close();
  }
}
