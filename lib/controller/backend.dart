import 'dart:io';
import 'dart:math';

import 'package:actor_project/models/actor_model.dart';
import 'package:actor_project/screens/widgets/show_SnackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseController {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  CollectionReference actorCollections =
      FirebaseFirestore.instance.collection('actors');

  Future<String?> storeImage(
      File file, String actorName, BuildContext context) async {
    try {
      Reference reference =
          _firebaseStorage.ref().child('actorImages').child(actorName);

      UploadTask uploadTask = reference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await reference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      showSnackBar(context: context, text: e.toString());
    }
  }

  Future<ActorModel?> saveDataAndGet(
      {required String actorName,
      required String imageUrl,
      required BuildContext context}) async {
    try {
      final documentRef =
          await actorCollections.add({'name': actorName, 'imageUrl': imageUrl});

      final documentSnapshot = await actorCollections.doc(documentRef.id).get();

      final mapOfData = documentSnapshot.data() as Map<String, dynamic>;
      final actorModel = ActorModel(
          docId: documentSnapshot.id,
          name: mapOfData['name'],
          imageUrl: mapOfData['imageUrl']);

      return actorModel;
    } on FirebaseException catch (e) {
      showSnackBar(context: context, text: e.toString());
    } catch (e) {
      showSnackBar(context: context, text: e.toString());
    }
  }

  Stream<List<ActorModel>>? getAllFavouriteActors(BuildContext context) {
    try {
      return actorCollections.snapshots().map((querySnapShot) {
        final listOfDocuments = querySnapShot.docs;

        return listOfDocuments.map((document) {
          final mapOfData = document.data() as Map<String, dynamic>;
          final actorModel = ActorModel(
              docId: document.id,
              name: mapOfData['name'],
              imageUrl: mapOfData['imageUrl']);
          return actorModel;
        }).toList();
      });
    } on FirebaseException catch (e) {
      showSnackBar(context: context, text: e.toString());
    } catch (e) {
      showSnackBar(context: context, text: e.toString());
    }
  }
}
