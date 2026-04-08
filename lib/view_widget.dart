import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

// Marque com @Preview para aparecer no painel
@Preview(name: 'Botão Principal')
Widget meuBotaoPreview() {
  return ElevatedButton(
    onPressed: () {},
    child: const Text('Clique Aqui'),
  );
}