import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:macrolite/core/navigation/app_router_provider.dart';

enum AddFoodOption { scan, manual }

class AddFoodFab extends StatelessWidget {
  const AddFoodFab({super.key});

  void _onSelected(BuildContext context, AddFoodOption option) {
    // Menüden bir seçenek seçildiğinde bu metot çalışır.
    switch (option) {
      case AddFoodOption.scan:
        context.push(AppRoute.scanner);
        break;
      case AddFoodOption.manual:
        context.push(AppRoute.addFood);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AddFoodOption>(
      onSelected: (option) => _onSelected(context, option),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<AddFoodOption>>[
        const PopupMenuItem<AddFoodOption>(
          value: AddFoodOption.scan,
          child: ListTile(
            leading: Icon(Icons.qr_code_scanner),
            title: Text('Barkod Tara'),
          ),
        ),
        const PopupMenuItem<AddFoodOption>(
          value: AddFoodOption.manual,
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manuel Ekle'),
          ),
        ),
      ],
      child: const FloatingActionButton(
        onPressed: null,
        tooltip: 'Yiyecek Ekle',
        child: Icon(Icons.add),
      ),
    );
  }
}