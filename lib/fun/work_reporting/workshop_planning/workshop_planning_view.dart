import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'workshop_planning_logic.dart';
import 'workshop_planning_state.dart';

class WorkshopPlanningPage extends StatefulWidget {
  const WorkshopPlanningPage({super.key});

  @override
  State<WorkshopPlanningPage> createState() => _WorkshopPlanningPageState();
}

class _WorkshopPlanningPageState extends State<WorkshopPlanningPage> {
  final WorkshopPlanningLogic logic = Get.put(WorkshopPlanningLogic());
  final WorkshopPlanningState state = Get.find<WorkshopPlanningLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    Get.delete<WorkshopPlanningLogic>();
    super.dispose();
  }
}