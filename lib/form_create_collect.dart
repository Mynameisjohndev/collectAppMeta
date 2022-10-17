import 'package:flutter/material.dart';

class CreteCollectForm extends StatefulWidget {
  const CreteCollectForm({super.key});

  @override
  State<CreteCollectForm> createState() => _CreteCollectFormState();
}

class _CreteCollectFormState extends State<CreteCollectForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(hintText: "Usuario"),
        ),
        TextField(
          decoration: InputDecoration(hintText: "Senha"),
        ),
      ],
    );
  }
}
