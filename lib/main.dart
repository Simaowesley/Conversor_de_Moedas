import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

var request = Uri.parse("https://api.hgbrasil.com/finance?key=133dffa1");

void main() async {
  runApp(
    MaterialApp(
      home: const Homes(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Homes extends StatefulWidget {
  const Homes({Key? key}) : super(key: key);

  @override
  _HomesState createState() => _HomesState();
}

class _HomesState extends State<Homes> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0;
  double euro = 0;

  void _clean() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }

  void _realc(String text) {
    if (text.isEmpty) {
      _clean();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolar(String text) {
    if (text.isEmpty) {
      _clean();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euro(String text) {
    if (text.isEmpty) {
      _clean();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('\$ Conversor De Moeda \$'),
          centerTitle: true,
          backgroundColor: Colors.amber,
          actions: [
            IconButton(onPressed: _clean, icon: const Icon(Icons.refresh))
          ],
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Column(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 200),
                        ),
                        CircularProgressIndicator(
                          color: Colors.amber,
                        ),
                        Text(
                          'Carregando Dados...',
                          style: TextStyle(color: Colors.green, fontSize: 25),
                        )
                      ],
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Erro ÃO Carregar dados...',
                        style: TextStyle(color: Colors.red, fontSize: 25),
                      ),
                    );
                  } else {
                    dolar =
                        snapshot.data!['results']['currencies']['USD']['buy'];
                    euro =
                        snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(Icons.monetization_on,
                                size: 150, color: Colors.amber),
                            const Divider(),
                            buildTextField(
                                "Reais", "R\$", realController, _realc),
                            const Divider(),
                            buildTextField(
                              "Dólares",
                              "US\$",
                              dolarController,
                              _dolar,
                            ),
                            const Divider(),
                            buildTextField(
                              "Euros",
                              "€",
                              euroController,
                              _euro,
                            )
                          ],
                        ),
                      ),
                    );
                  }
              }
            }));
  }

  Widget buildTextField(
      String label, String prefix, TextEditingController c, Function f) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber, fontSize: 25),
        prefixText: prefix,
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(
        color: Colors.amber,
        fontSize: 25,
      ),
      onChanged: (t) {
        f(t);
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
