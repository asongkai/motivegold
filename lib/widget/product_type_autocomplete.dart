import 'package:flutter/material.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/product_type.dart';

class ProductTypeAutocompleteTextField extends StatefulWidget {
  final List<ProductTypeModel> items;
  final Function(String) onItemSelect;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;
  const ProductTypeAutocompleteTextField(
      {Key? key,
        required this.items,
        required this.onItemSelect,
        this.decoration,
        this.validator})
      : super(key: key);

  @override
  State<ProductTypeAutocompleteTextField> createState() => _ProductTypeAutocompleteTextFieldState();
}

class _ProductTypeAutocompleteTextFieldState extends State<ProductTypeAutocompleteTextField> {
  final FocusNode _focusNode = FocusNode();
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late List<ProductTypeModel> _filteredItems;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry);
      } else {
        _overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        style: const TextStyle(fontSize: 38),
        onChanged: _onFieldChange,
        decoration: widget.decoration,
        validator: widget.validator,
      ),
    );
  }

  void _onFieldChange(String val) {
    setState(() {
      if (val == '') {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
                (element) => element.code.toString().toLowerCase().contains(val.toLowerCase()))
            .toList();
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
        builder: (context) => Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 5.0),
            child: Material(
              elevation: 4.0,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  itemCount: _filteredItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _filteredItems[index];
                    return ListTile(
                      title: Text(item.code!, style: const TextStyle(fontSize: 32),),
                      onTap: () {
                        _controller.text = item.code!;
                        _focusNode.unfocus();
                        widget.onItemSelect(item.code.toString());
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ));
  }
}