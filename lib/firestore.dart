import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection("users");

  Future<void> addUser(String uid) {
    return usersCollection.add({"uid": uid, "routines": []});
  }

  Future<String> addRoutine(String uid, Map<String, dynamic> routine) async {
    QuerySnapshot querySnapshot = await usersCollection
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      try {
        String docId = querySnapshot.docs[0].id;
        final docRef = await usersCollection.doc(docId).collection("routines").add(routine);
        return docRef.id;
      } catch (e) {
        print(e);
      }
    } 
    return "";
  }

  Future<void> updateRoutine(
    String uid,
    String routineId,
    Map<String, dynamic> routine,
  ) async {
    QuerySnapshot querySnapshot = await usersCollection
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      try {
        String docId = querySnapshot.docs[0].id;
        await usersCollection
            .doc(docId)
            .collection("routines")
            .doc(routineId)
            .update(routine);
      } catch (e) {
        print(e);
      }
    }
  }

  Stream<QuerySnapshot> getRoutinesStream(String uid) async* {
    QuerySnapshot querySnapshot = await usersCollection
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get();
    String docId = querySnapshot.docs[0].id;
    yield* usersCollection.doc(docId).collection("routines").snapshots();
  }

  Future<void> deleteRoutine(String routineId, String uid) async {
    QuerySnapshot querySnapshot = await usersCollection
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get();

    String docId = querySnapshot.docs[0].id;

    return usersCollection
        .doc(docId)
        .collection("routines")
        .doc(routineId)
        .delete();
  }

}

// [
//  {
//   "name": "Ascending note values",
//    "id": "q45u98awefasdf234"
//   "stickings": [],
//   "notes": [],
//   "timeSignature": [4,4],
//   "barValues": []
// }
// ]
