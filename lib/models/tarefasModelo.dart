class TarefaModelo {
  String id;
  String descricao;
  bool concluido;

  TarefaModelo({
    required this.id,
    required this.descricao,
    required this.concluido,
  });

  TarefaModelo.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        descricao = map['descricao'],
        concluido = map['concluido'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'concluido': concluido,
    };
  }
}
