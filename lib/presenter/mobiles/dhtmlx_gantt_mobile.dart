import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dhtmlx/controllers/gantt_controller.dart';
import 'package:flutter_dhtmlx/models/gantt_model.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DhtmlxGantt extends StatefulWidget {
  @override
  _DhtmlxGanttState createState() => _DhtmlxGanttState();
}

class _DhtmlxGanttState extends State<DhtmlxGantt> {
  final ganttController = GanttController();

  late InAppWebViewController _webViewController;
  String htmlContent = '';

  @override
  void initState() {
    super.initState();
    loadLocalFiles();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _setupEventListeners();
    });
  }

  Future<void> loadLocalFiles() async {
    final css = await rootBundle.loadString('assets/dhtmlxgantt.css');
    final js = await rootBundle.loadString('assets/dhtmlxgantt.js');
    final ganttInit = await ganttController.getListMapGantt();

    setState(() {
      htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <style>$css</style>
  <script>$js</script>
  <script>
    document.addEventListener("DOMContentLoaded", function() {
      if (document.getElementById('gantt_here')) {
          gantt.config.date_format = "%Y-%m-%d %H:%i:%s";
            gantt.init('gantt_here');
            gantt.parse({data: ${jsonEncode(ganttInit)}}); // Inicializa com dados vazios
            setupGanttEvents();
        } else {
            setTimeout(initGantt, 50);
        }
    });

    function setupGanttEvents() {
        gantt.attachEvent('onAfterTaskAdd', function(id, item) {
            window.flutter_inappwebview.callHandler('handleTaskAdded', JSON.stringify({id: id, item: item}));
        });
        gantt.attachEvent('onAfterTaskUpdate', function(id, item) {
            window.flutter_inappwebview.callHandler('handleTaskUpdated', JSON.stringify({id: id, item: item}));
        });
        gantt.attachEvent('onAfterTaskDelete', function(id) {
            window.flutter_inappwebview.callHandler('handleTaskDeleted', id);
        });
    }

    function addTask(task) {
        task.start_date = new Date(task.start_date); 
        gantt.addTask(task);
    }

    function updateTask(taskId, changes) {
        if (changes.start_date) {
            changes.start_date = new Date(changes.start_date); 
        }
        var task = gantt.getTask(taskId);
        Object.assign(task, changes);
        gantt.updateTask(taskId);
    }

    function deleteTask(taskId) {
        gantt.deleteTask(taskId);
    }
  </script>
</head>
<body>
  <div id="gantt_here" style="width:100%; height:100vh;"></div>
</body>
</html>
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DHTMLx Gantt"),
      ),
      body: InAppWebView(
        key: UniqueKey(),
        initialData: InAppWebViewInitialData(data: htmlContent),
        onWebViewCreated: (controller) {
          _webViewController = controller;
          controller.addJavaScriptHandler(
              handlerName: 'handleTaskAdded',
              callback: (args) {
                final map = jsonDecode(args[0]);
                final gantt = GanttModel.fromMap(map['item']);
                ganttController.addGant(gantt);
                print('Task Added: ${args[0]}');
              });
          controller.addJavaScriptHandler(
              handlerName: 'handleTaskUpdated',
              callback: (args) {
                final map = jsonDecode(args[0]);
                final gantt = GanttModel.fromMap(map['item']);
                ganttController.updateGantt(gantt);
                print('Task Updated: ${args[0]}');
              });
          controller.addJavaScriptHandler(
              handlerName: 'handleTaskDeleted',
              callback: (args) {
                ganttController.deleteGantt(args[0]);
                print('Task Deleted: ${args[0]}');
              });
        },
      ),
    );
  }
}
