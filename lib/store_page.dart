import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class StorePage extends StatefulWidget {
  final String spreadsheetId;

  StorePage({required this.spreadsheetId});

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<dynamic> _products = [];
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Fetch products from Google Sheet
  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse(
        'https://script.google.com/macros/s/XXXXXX/exec?spreadsheetId=${widget.spreadsheetId}')); // Replace with your Web App URL
    if (response.statusCode == 200) {
      setState(() {
        _products = json.decode(response.body);
      });
    }
  }

  // Add a new product to Google Sheet
  Future<void> _addProduct() async {
    final newProduct = {
      'Product Name': _productNameController.text,
      'Price': _priceController.text,
      'Description': _descriptionController.text,
      'Image URL': _imageUrlController.text,
    };

    final response = await http.post(
      Uri.parse('https://script.google.com/macros/s/XXXXXX/exec'), // Replace with your Web App URL
      body: {
        'spreadsheetId': widget.spreadsheetId,
        'product': json.encode(newProduct),
      },
    );

    if (response.statusCode == 200) {
      _fetchProducts(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Store')),
      body: _products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl: product['Image URL'],
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['Product Name'], style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${product['Price']}'),
                            Text(product['Description'], maxLines: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _productNameController, decoration: InputDecoration(labelText: 'Product Name')),
            TextField(controller: _priceController, decoration: InputDecoration(labelText: 'Price')),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description')),
            TextField(controller: _imageUrlController, decoration: InputDecoration(labelText: 'Image URL')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addProduct();
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}