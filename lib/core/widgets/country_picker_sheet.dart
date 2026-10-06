import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../utils/countries.dart';

class CountryPickerSheet extends StatefulWidget {
  final Function(Country) onSelect;

  const CountryPickerSheet({super.key, required this.onSelect});

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  List<Country> filtered = Countries.all;
  final search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            AppLocalizations.of(context)!.selectCountry,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: search,
            onChanged: _filter,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: AppLocalizations.of(context)!.searchCountry,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c = filtered[i];

                return ListTile(
                  onTap: () {
                    widget.onSelect(c);
                    Navigator.pop(context);
                  },
                  leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                  title: Text(c.name),
                  trailing: Text(c.dialCode),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _filter(String value) {
    setState(() {
      filtered = Countries.all
          .where((c) => c.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }
}
