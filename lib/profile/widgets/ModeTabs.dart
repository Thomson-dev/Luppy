import 'package:flutter/material.dart';

class ModeTabs extends StatelessWidget {
  final TabController controller;
 
  const ModeTabs({super.key, required this.controller});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.pink),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        splashFactory: NoSplash.splashFactory,
        tabs: const [
          Tab(height: 35, text: 'Edit'),
          Tab(height: 35, text: 'Preview'),
        ],
      ),
    );
  }
}