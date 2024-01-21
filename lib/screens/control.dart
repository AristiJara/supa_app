import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ControlScreenState();
  }
}

class _ControlScreenState extends State<ControlScreen> {
  final foodAmountController = TextEditingController();
  final ref = FirebaseDatabase.instance.ref();
  bool on = false;
  bool nivel = false;
  String valorSensor = "0.00";
  String selectedTimeText = '';
  TimeOfDay selectedTime = TimeOfDay.now();
  
  
  @override
  void initState() {
    super.initState();

    ref.child("Sensor/gramos").onValue.listen((event) {
      setState(() {
        valorSensor = event.snapshot.value.toString(); // Convertir a String
      });
    });

    // Escuchar cambios en el valor de comidaBaja
    ref.child("Nivel/bool").onValue.listen((event) {
      setState(() {
        nivel = (event.snapshot.value as bool?) ?? false;
      });
    });
  }

  void _timeAdd() async {
    final buttonColor = Theme.of(context).colorScheme.primary; // Define buttonColor localmente

    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context, 
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: buttonColor,
            hintColor: buttonColor,
            primaryTextTheme: TextTheme(
              titleMedium: TextStyle(fontSize: 24, color: buttonColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (timeOfDay != null) {
      final formattedHour = "${timeOfDay.hour}";
      final formattedMinute = "${timeOfDay.minute}".padLeft(2, '0');
      final formattedTime = "$formattedHour:$formattedMinute"; // Formatea el tiempo como una cadena
      setState(() {
        selectedTime = timeOfDay;
        selectedTimeText = formattedTime; // Actualiza la variable selectedTimeText
      });

      ref.child("Time/hh:mm").set(selectedTimeText);
    }
  }

  void _alimentar() {
    // Envía la cantidad de comida a Firebase
    ref.child("Alimentar").set({"bool": true,});
    foodAmountController.clear();

    setState(() {
      on = !on;
    });
  }

  void _guardarCantidad() {
    final foodAmount = foodAmountController.text; // Obtén el valor del TextField

    if (foodAmount.isNotEmpty) {
      // Envía la cantidad de comida a Firebase
      ref.child("Cantidad/gramos").set(foodAmount);
      foodAmountController.clear();
    } else {
      // Maneja el caso en que el valor del TextField está vacío
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SUPA',
          style: TextStyle(
            color: Colors.white, 
          ),
        ),
        backgroundColor: buttonColor,
        actions: [
          IconButton(
            onPressed: _timeAdd,
            icon: const Icon(
              Icons.alarm, 
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white, 
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: 4,
                  color: buttonColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Hora de comer',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.white,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          selectedTimeText,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.white,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!nivel)
                  const Card(
                    elevation: 4,
                    margin: EdgeInsets.all(16),
                    color: Colors.red, // Cambia el color del Card a rojo
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No hay alimento en el dispensador',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white, // Ajusta el color del texto si es necesario
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.white,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 140),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/food_pet.png',
                      width: 300,
                    ),
                    Positioned(
                      top: 125, // Ajusta la posición del texto
                      child: Text(
                        '$valorSensor gr',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                          shadows: [
                            Shadow(
                              blurRadius: 5,
                              color: buttonColor,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: foodAmountController,
                    keyboardType: TextInputType.number, // Teclado numérico
                    decoration: const InputDecoration(
                      labelText: 'Cantidad de alimento (gr)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _guardarCantidad,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding: const EdgeInsets.all(16),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // Agregado un espacio entre los botones
                    ElevatedButton(
                      onPressed: _alimentar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding: const EdgeInsets.all(16),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Alimentar',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}