import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/pages/account_page.dart';
import 'package:fyp_project/widgets/OwnerDrawer.dart';
import 'package:get/get.dart';

class DashboardOwner extends StatelessWidget {

  const DashboardOwner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("INTI Accommodation Finder"),
        centerTitle: true,
        actions: [IconButton(
          // placeholder icon fix later
          icon: const Icon(Icons.account_tree_outlined),
          // same thing here
          onPressed: () => {
            Get.to(() => AccountPage(),
            transition: Transition.circularReveal,
            duration: const Duration(seconds: 1))
          },
        )],
      ),
      drawer: Ownerdrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InformationCard(),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Title",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 200, child: LineChart(mainData())), // Graph here
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Bottom buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                    },
                    child: Text("Manage Rooms", style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      // Chat logic
                    },
                    child: Text("Chat", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container InformationCard() {
    return Container(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  width: 200,
                  child: Card(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "placeholder",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "\$45,678.90",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text("placeholder"),
                      ],
                    ),
                  ),
                                  ),
                ),
                SizedBox(width: 20,),
                Container(
                  width: 200,
                  child: Card(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "placeholder",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "\$45,678.90",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text("placeholder"),
                      ],
                    ),
                  ),
                  ),
                ),
                SizedBox(width: 20,),
                Container(
                  width: 200,
                  child: Card(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "placeholder",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "\$45,678.90",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text("placeholder"),
                      ],
                    ),
                  ),
                  ),
                ),
                SizedBox(width: 20,),
                Container(
                  width: 200,
                  child: Card(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "placeholder",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "\$45,678.90",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text("placeholder"),
                      ],
                    ),
                  ),
                  ),
                ),
              ],
            ),
          );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(show: true),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 3),
            FlSpot(1, 2),
            FlSpot(2, 5),
            FlSpot(3, 3.1),
            FlSpot(4, 4),
            FlSpot(5, 3),
            FlSpot(6, 4),
            FlSpot(7, 3),
            FlSpot(8, 5),
            FlSpot(9, 4),
            FlSpot(10, 5),
          ],
          isCurved: true,
          color: Colors.black,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
        ),
      ],
    );
  }
}
