import 'package:flutter/material.dart';
import 'package:todoflutter/componentes/decoracaolabel.dart';
import 'package:todoflutter/comum/minhascores.dart';
import 'package:todoflutter/models/tarefasModelo.dart';
import 'package:todoflutter/servicos/autenticacao_serv.dart';
import 'package:todoflutter/servicos/tarefa_serv.dart';
import 'package:uuid/uuid.dart';

class ToDo extends StatefulWidget {
  final TarefaModelo? tarefaModelo;
  const ToDo({super.key, this.tarefaModelo});

  @override
  State<ToDo> createState() => _ToDoState();
}

class _ToDoState extends State<ToDo> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nomeCrtl = TextEditingController();

  final TarefaServico _tarefaServico = TarefaServico();

  final TarefaServico servico = TarefaServico();
  List<TarefaModelo> listaTarefas = [];
  bool mostrarConcluidas = false;

  @override
  void initState() {
    if (widget.tarefaModelo != null) {
      nomeCrtl.text = widget.tarefaModelo!.descricao;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<TarefaModelo> tarefasExibidas =
        mostrarConcluidas ? getTarefasConcluidas() : listaTarefas;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('deslogar'),
              onTap: () {
                AutenticacaoServ().deslogar();
              },
            ),
          ],
        ),
      ),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: nomeCrtl,
                      decoration: getDecoretion('Tarefa'),
                      validator: (String? value) {
                        if (value == null) {
                          return 'nao pode ser vazio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () {
                            botaoPrincipal();
                          },
                          child: const Text('Adicionar')),
                    ),
                    const Divider(),
                    StreamBuilder(
                      stream: servico.conctarStreamTarefa(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          if (snapshot.hasData &&
                              snapshot.data != null &&
                              snapshot.data!.docs.isNotEmpty) {
                            List<TarefaModelo> listaTarefas = [];

                            for (var doc in snapshot.data!.docs) {
                              listaTarefas
                                  .add(TarefaModelo.fromMap(doc.data()));
                            }

                            return SizedBox(
                              height: 250,
                              child: ListView(
                                children: List.generate(
                                  listaTarefas.length,
                                  (index) {
                                    TarefaModelo tarefaModelo =
                                        listaTarefas[index];
                                    return ListTile(
                                      title: Text(tarefaModelo.descricao),
                                      leading: Icon(
                                        tarefaModelo.concluido
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: tarefaModelo.concluido
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          toggleConcluido(tarefaModelo);
                                        });
                                      },
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                              editarTarefa(tarefaModelo);
                                            },
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                servico.removerTarefa(
                                                    idTarefa: tarefaModelo.id);
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ))
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          } else {
                            return const Center(
                              child: Text("sem tarefas add"),
                            );
                          }
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            mostrarConcluidas =
                !mostrarConcluidas; // Alternar o estado ao clicar
          });
        },
        child: Icon(Icons.filter_list),
        tooltip: mostrarConcluidas
            ? 'Mostrar Todas as Tarefas'
            : 'Mostrar Tarefas Concluídas',
      ),
    );
  }

  List<TarefaModelo> getTarefasConcluidas() {
    return listaTarefas.where((tarefa) => tarefa.concluido).toList();
  }

  void toggleConcluido(TarefaModelo tarefa) {
    tarefa.concluido =
        !tarefa.concluido; // Alterna entre concluído e não concluído
    _tarefaServico.adicionarTarefa(tarefa);
  }

  botaoPrincipal() {
    String nome = nomeCrtl.text;
    TarefaModelo tarefa =
        TarefaModelo(id: const Uuid().v1(), descricao: nome, concluido: false);
    _tarefaServico.adicionarTarefa(tarefa);
    if (widget.tarefaModelo != null) {
      tarefa.id = widget.tarefaModelo!.id;
    }
    if (_formKey.currentState!.validate()) {
      print("ta ok");
    }
  }

  void editarTarefa(TarefaModelo tarefa) {
    TextEditingController editarNomeCtrl =
        TextEditingController(text: tarefa.descricao);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar Tarefa"),
          content: TextFormField(
            controller: editarNomeCtrl,
            decoration: getDecoretion('Nova Descrição'),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Descrição inválida';
              }
              return null;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                String novaDescricao = editarNomeCtrl.text;
                if (novaDescricao.isNotEmpty) {
                  tarefa.descricao = novaDescricao;
                  _tarefaServico.adicionarTarefa(tarefa);
                }
                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
