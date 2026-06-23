import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/favorites_provider.dart';
import '../../core/theme.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Saved Items'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favorites, _) {
          if (favorites.favoriteCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No saved items yet',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          // In a real app, we'd fetch the actual data for these IDs.
          // For FYP 1, we'll show a message or a simplified list.
          // Since we already have streams in other screens, 
          // we could combine them, but for demo simplicity, 
          // let's show that we track the IDs correctly.

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.favoriteIds.length,
            itemBuilder: (context, index) {
              final id = favorites.favoriteIds.elementAt(index);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text('Saved Item: $id'),
                  subtitle: const Text('Added to favorites'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => favorites.toggleFavorite(id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
