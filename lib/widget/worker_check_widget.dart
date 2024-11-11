import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../bean/http/response/worker_info.dart';
import '../utils/web_api.dart';

///自定义输入框 根据工号查询员工
class WorkerCheck extends StatefulWidget {
  const WorkerCheck({super.key, required this.onChanged, this.hint, this.init});

  final Function(WorkerInfo?) onChanged;
  final String? hint;
  final String? init;

  @override
  State<WorkerCheck> createState() => _WorkerCheckState();
}

class _WorkerCheckState extends State<WorkerCheck> {
  var controller = TextEditingController();
  var name = ''.obs;
  var error = ''.obs;

  getWorker({
    required String number,
    required Function(WorkerInfo) success,
    required Function(String) error,
  }) {
    httpGet(method: webApiGetWorkerInfo, params: {
      'EmpNumber': number,
      'DeptmentID': '',
    }).then((worker) {
      if (worker.resultCode == resultSuccess) {
        success.call(WorkerInfo.fromJson(worker.data[0]));
      } else {
        error.call(worker.message ?? '');
      }
    });
  }
  @override
  void initState() {
    if(widget.init?.isNotEmpty==true){
      controller.text=widget.init!;
      checkWorker(widget.init!);
    }
    super.initState();
  }

  checkWorker(String number) {
    if (number.length >= 6) {
      getWorker(
          number: number,
          success: (worker) {
            name.value = worker.empName ?? '';
            error.value = '';
            widget.onChanged.call(worker);
          },
          error: (s) {
            name.value = '';
            error.value = s;
            widget.onChanged.call(null);
          });
    } else {
      name.value = '';
      error.value = '';
      widget.onChanged.call(null);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Obx(
            () => TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: controller,
          onChanged: (s) =>checkWorker(s),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(
              top: 0,
              bottom: 0,
              left: 10,
              right: 10,
            ),
            filled: true,
            fillColor: Colors.grey[300],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Colors.transparent,
              ),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            helperText: name.value,
            helperStyle: TextStyle(color: Colors.green.shade700),
            errorText: error.value.isNotEmpty ? error.value : null,
            hintText: widget.hint != null && widget.hint!.isNotEmpty
                ? widget.hint
                : '请输入员工工号',
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                controller.clear();
                name.value = '';
                error.value = '';
                widget.onChanged.call(null);
              },
            ),
          ),
        ),
      ),
    );
  }
}