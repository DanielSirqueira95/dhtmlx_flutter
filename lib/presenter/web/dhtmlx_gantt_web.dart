import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;
import 'dart:ui_web';
import 'package:flutter/material.dart';
import 'package:flutter_dhtmlx/controllers/gantt_controller.dart';
import 'package:flutter_dhtmlx/models/gantt_model.dart';

class DhtmlxGantt extends StatefulWidget {
  @override
  _DhtmlxGanttState createState() => _DhtmlxGanttState();
}

class _DhtmlxGanttState extends State<DhtmlxGantt> {
  final UniqueKey _key = UniqueKey();

  final ganttController = GanttController();

  @override
  void initState() {
    super.initState();
    PlatformViewRegistry().registerViewFactory(
      'dhtmlx-gantt',
      (int viewId) => DivElement()
        ..id = 'gantt-container'
        ..style.width = '100%'
        ..style.height = '100%',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var tasks = await ganttController
          .getListMapGantt(); // Assumindo que isso retorna uma lista de mapas
      js.context.callMethod('initGantt', [js.JsObject.jsify(tasks)]);
      _setupEventListeners();
    });
  }

  void _setupEventListeners() {
    window.addEventListener('onTaskAdded', (event) {
      var detail = jsonDecode(js.JsObject.fromBrowserObject(event)['detail']);
      final gantt = GanttModel.fromMap(detail['item']);
      ganttController.addGant(gantt);
      print('Task Added: $detail');
    });
    window.addEventListener('onTaskUpdated', (event) {
      var detail = jsonDecode(js.JsObject.fromBrowserObject(event)['detail']);
      final gantt = GanttModel.fromMap(detail['item']);
      ganttController.updateGantt(gantt);
      print('Task Updated: $detail');
    });
    window.addEventListener('onTaskDeleted', (event) {
      var detail = jsonDecode(js.JsObject.fromBrowserObject(event)['detail']);
      ganttController.deleteGantt(detail['id']);
      print('Task Deleted: $detail');
    });
  }

  void addTask(Map<String, dynamic> task) {
    js.context.callMethod('addTask', [js.JsObject.jsify(task)]);
  }

  void updateTask(int taskId, Map<String, dynamic> changes) {
    js.context.callMethod('updateTask', [taskId, js.JsObject.jsify(changes)]);
  }

  void deleteTask(int taskId) {
    js.context.callMethod('deleteTask', [taskId]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DHTMLx Gantt"),
      ),
      body: HtmlElementView(key: _key, viewType: 'dhtmlx-gantt'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example of how to call addTask
          addTask({
            'id': DateTime.now().millisecondsSinceEpoch,
            'text': 'New Task',
            'start_date': DateTime.now().toString(),
            'duration': 0.5,
            'parent': 1
          });
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
    );
  }
}
