import 'package:flutter/material.dart';
import 'package:todoflutter/componentes/decoracaolabel.dart';
import 'package:todoflutter/comum/meu_snackbar.dart';
import 'package:todoflutter/comum/minhascores.dart';
import 'package:todoflutter/servicos/autenticacao_serv.dart';

class Autenticacao extends StatefulWidget {
  const Autenticacao({super.key});

  @override
  State<Autenticacao> createState() => _AutenticacaoState();
}

class _AutenticacaoState extends State<Autenticacao> {
  bool queroEntra = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

  final AutenticacaoServ _auten = AutenticacaoServ();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MinhasCores.azulTopGradiente,
                MinhasCores.azulBaixoGradiente
              ],
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: getDecoretion('e-mail'),
                        validator: (String? value) {
                          if (value == null) {
                            return 'nao pode ser vazio';
                          }
                          if (value.length < 8) {
                            return 'muito pequeno tente de novo';
                          }
                          if (!value.contains("@")) {
                            return 'nao é um email valido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        controller: _senhaController,
                        decoration: getDecoretion('senha'),
                        obscureText: true,
                        validator: (String? value) {
                          if (value == null) {
                            return 'nao pode ser vazio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Visibility(
                        visible: !queroEntra,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nomeController,
                              decoration: getDecoretion('nome'),
                              validator: (String? value) {
                                if (value == null) {
                                  return 'nao pode ser vazio';
                                }
                                if (value.length < 8) {
                                  return 'muito pequeno tente de novo';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            botaoPrincipal();
                          },
                          child: Text((queroEntra) ? 'Entra' : 'Cadastrar')),
                      const Divider(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            queroEntra = !queroEntra;
                          });
                        },
                        child: Text((queroEntra)
                            ? 'Faça seu cadastro'
                            : 'Ja tem uma conta?! Click aqui'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  botaoPrincipal() {
    String nome = _nomeController.text;
    String email = _emailController.text;
    String senha = _senhaController.text;
    if (_formKey.currentState!.validate()) {
      if (queroEntra) {
        print('Entrada valido');
        _auten.logarUsuario(email: email, senha: senha).then((String? erro) {
          if (erro != null) {
            showSnackBar(context: context, texto: erro);
          }
        });
      } else {
        print('cadastrovalido');
        _auten
            .cadastrarUsuario(nome: nome, senha: senha, email: email)
            .then((String? erro) {
          if (erro != null) {
            //deu certo
            showSnackBar(context: context, texto: erro);
          }
        });
      }
    }
  }
}
