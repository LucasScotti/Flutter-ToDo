import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todoflutter/models/tarefasModelo.dart';

class TarefaServico {
  String userId;
  TarefaServico() : userId = FirebaseAuth.instance.currentUser!.uid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> adicionarTarefa(TarefaModelo tarefaModelo) async {
    return await _firestore
        .collection(userId)
        .doc(tarefaModelo.id)
        .set(tarefaModelo.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> conctarStreamTarefa() {
    return _firestore.collection(userId).snapshots();
  }

  Future<void> removerTarefa({required String idTarefa}) {
    return _firestore.collection(userId).doc(idTarefa).delete();
  }
}
