import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';

class SearchableTransactionDropdown extends HookWidget {
  final List<Transaction> transactions;
  final String? value;
  final ValueChanged<String?> onChanged;

  const SearchableTransactionDropdown({
    super.key,
    required this.transactions,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final query = useState('');
    final isOpen = useState(false);
    final focusNode = useFocusNode();
    final isPressingList = useState(false);

    useEffect(() {
      searchController.text = value ?? '';
      query.value = value ?? '';
      return null;
    }, [value]);

    useEffect(() {
      void listener() {
        if (!focusNode.hasFocus && !isPressingList.value) {
          isOpen.value = false;
          searchController.text = value ?? '';
          query.value = value ?? '';
        }
      }
      focusNode.addListener(listener);
      return () => focusNode.removeListener(listener);
    }, [focusNode, value, isPressingList]);

    final filtered = transactions
        .where((t) =>
            t.transactionNumber.toLowerCase().contains(query.value.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          focusNode: focusNode,
          style: GoogleFonts.outfit(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Transaction Number',
            labelStyle: GoogleFonts.outfit(color: posTextMuted),
            filled: true,
            fillColor: posSurfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: posPrimary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            suffixIcon: Icon(
              isOpen.value ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: posTextMuted,
            ),
          ),
          onTap: () => isOpen.value = true,
          onChanged: (v) {
            query.value = v;
            isOpen.value = true;
            if (v.isEmpty) onChanged(null);
          },
        ),
        if (isOpen.value && filtered.isNotEmpty)
          Listener(
            onPointerDown: (_) => isPressingList.value = true,
            onPointerUp: (_) => isPressingList.value = false,
            onPointerCancel: (_) => isPressingList.value = false,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: posPrimary, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Material(
                  color: posSurfaceLight,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final t = filtered[i];
                      final isSelected = t.transactionNumber == value;
                      return Ink(
                        color: isSelected
                            ? posPrimary.withValues(alpha: 0.15)
                            : Colors.transparent,
                        child: InkWell(
                          hoverColor: posPrimary.withValues(alpha: 0.10),
                          onTap: () {
                            onChanged(t.transactionNumber);
                            searchController.text = t.transactionNumber;
                            query.value = t.transactionNumber;
                            isOpen.value = false;
                            focusNode.unfocus();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Text(
                              t.transactionNumber,
                              style: GoogleFonts.outfit(
                                color: isSelected ? posPrimary : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
