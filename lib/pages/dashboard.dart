import 'package:flutter/material.dart';

import 'home_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin
{
  TabController? controller;
  int indexSelected = 0;


  onBarItemClicked(int i)
  {
    setState(() {
      indexSelected = i;
      controller!.index = indexSelected;
    });
  }

  @override
  void initState()
  {
    super.initState();

    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose()
  {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller,
          children: const [
            HomePage(),
            // TripsPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const
          [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_tree),
                label: "Trips"
            ),
          ],
          currentIndex: indexSelected,
          //backgroundColor: Colors.grey,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.green,
          showSelectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          onTap: onBarItemClicked,
        )
      );
  }
}
