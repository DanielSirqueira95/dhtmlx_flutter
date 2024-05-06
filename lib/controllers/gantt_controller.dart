import 'dart:convert';

import 'package:flutter_dhtmlx/models/gantt_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GanttController {
  Future<void> addGant(GanttModel gantt) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final listMap = await getListMapGantt();

    listMap.add(gantt.toMap());

    prefs.setString('gantt', jsonEncode(listMap));
    print(
        "Dados salvos: ${jsonEncode(listMap)}"); // Adicionar esta linha para depuração
  }

  Future<void> updateGantt(GanttModel gantt) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listMap = List.from(await getListMapGantt());

    listMap = listMap.map((map) {
      final mapGantt = GanttModel.fromMap(map);

      if (mapGantt.id == gantt.id) {
        return gantt.toMap();
      }

      return map;
    }).toList();

    prefs.setString('gantt', jsonEncode(listMap));
  }

  Future<void> deleteGantt(int ganttId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listMap = List.from(await getListMapGantt());

    listMap = listMap.where((map) {
      final mapGantt = GanttModel.fromMap(map);

      return mapGantt.id != ganttId;
    }).toList();

    prefs.setString('gantt', jsonEncode(listMap));
  }

  Future<List<Map<String, dynamic>>> getListMapGantt() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonGantt = prefs.getString('gantt');

    if (jsonGantt != null) {
      final data = List<Map<String, dynamic>>.from(jsonDecode(jsonGantt));
      print("Dados recuperados: $data"); // Verificação de depuração
      return data;
    }

    return [];
  }
}
