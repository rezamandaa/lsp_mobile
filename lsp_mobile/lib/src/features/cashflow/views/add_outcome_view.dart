import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lsp_mobile/cores/constants/color_const.dart';
import 'package:lsp_mobile/src/models/cash_flow_model.dart';
import 'package:lsp_mobile/src/repositories/sqlite_repository.dart';

class AddOutcomeView extends StatefulWidget {
  const AddOutcomeView({super.key});

  @override
  State<AddOutcomeView> createState() => _AddOutcomeViewState();
}

class _AddOutcomeViewState extends State<AddOutcomeView> {
  final _formKey = GlobalKey<FormState>();

  final SQLiteRepository _sqliteRepository = SQLiteRepository();

  TextEditingController dateController = TextEditingController();
  TextEditingController nominalController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void addOutcome() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    CashFlowModel cashFlowModel = CashFlowModel(
      date: dateController.text,
      amount: int.tryParse(nominalController.text) ?? 0,
      description: descriptionController.text,
      type: 0,
    );

    int result =
        await _sqliteRepository.insert('cashflow', cashFlowModel.toJson());

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil menambahkan pengeluaran'),
        ),
      );
      reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menambahkan pengeluaran'),
        ),
      );
    }
  }

  void reset() {
    dateController.clear();
    nominalController.clear();
    descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.red.shade600,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Tambah Pengeluaran',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Colors.red.shade600,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.datetime,
                      controller: dateController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal tidak boleh kosong';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Pilih Tanggal',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                        label: Text(
                          'Tanggal',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(
                          top: 10,
                          left: 10,
                          bottom: 8,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.white,
                        ),
                        errorStyle: TextStyle(
                          color: ColorConst.secondary500,
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorConst.secondary500,
                          ),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now());
                        if (date != null) {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            String timeText = time.hour.toString().length == 1
                                ? '0${time.hour}'
                                : time.hour.toString();
                            timeText += ':';
                            timeText += time.minute.toString().length == 1
                                ? '0${time.minute}'
                                : time.minute.toString();
                            dateController.text =
                                '${date.toString().split(' ')[0]} $timeText';
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: nominalController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nominal tidak boleh kosong';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                        label: Text(
                          'Nominal',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(
                          top: 10,
                          left: 10,
                          bottom: 8,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        errorStyle: TextStyle(
                          color: ColorConst.secondary500,
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorConst.secondary500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      maxLines: 3,
                      controller: descriptionController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Keterangan',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                        label: Text(
                          'Keterangan',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(
                          top: 10,
                          left: 10,
                          bottom: 8,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        reset();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        addOutcome();
                      },
                      child: const Text('Simpan'),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
