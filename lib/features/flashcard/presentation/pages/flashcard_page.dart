import 'package:flutter/material.dart';

import '../controllers/flashcard_controller.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({
    required this.controller,
    super.key,
  });

  final FlashcardController controller;
}