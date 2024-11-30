import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cepController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  Future<void> _searchCEP() async {
    final cep = _cepController.text.trim();

    if (cep.isEmpty || !RegExp(r'^\d{8}$').hasMatch(cep)) {
      setState(() {
        _result = 'Por favor, insira um CEP válido com 8 dígitos.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('erro')) {
          _result = 'CEP não encontrado.';
        } else {
          _result = 'CEP: ${data['cep']}\n'
              'Logradouro: ${data['logradouro']}\n'
              'Complemento: ${data['complemento'] ?? 'N/A'}\n'
              'Bairro: ${data['bairro']}\n'
              'Localidade: ${data['localidade']}\n'
              'UF: ${data['uf']}';
        }
      } else {
        _result = 'Erro ao buscar o CEP. Tente novamente mais tarde.';
      }
    } catch (e) {
      _result = 'Erro de conexão. Verifique sua internet.';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const String fixedDate = '30/11/2024';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Consulta de CEP - Arthur Gonçalves Silva - $fixedDate',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'CEP'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _searchCEP,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Consultar'),
            ),
            const SizedBox(height: 16),
            if (_result.isNotEmpty)
              Text(
                _result,
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
