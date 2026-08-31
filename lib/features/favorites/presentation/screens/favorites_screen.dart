import 'package:flutter/material.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Center(
        child: Text(
          'Favorites Module Placeholder',
          style: context.textTheme.headlineSmall,
        ),
      ),
    );
  }
}
