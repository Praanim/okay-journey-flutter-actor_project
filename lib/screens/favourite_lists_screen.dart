import 'package:actor_project/controller/backend.dart';
import 'package:actor_project/models/actor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavouriteList extends StatelessWidget {
  final _firebaseController = FirebaseController();

  FavouriteList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourite List'),
      ),
      body: StreamBuilder<List<ActorModel>>(
        initialData: [],
        stream: _firebaseController.getAllFavouriteActors(context),
        builder:
            (BuildContext context, AsyncSnapshot<List<ActorModel>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null) {
            Text(
              'Error: Something went wrong',
              style: TextStyle(color: Colors.black),
            );
          }
          if (snapshot.data!.isEmpty) {
            Text(
              'Error: Something went wrong',
              style: TextStyle(color: Colors.black),
            );
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              final actor = snapshot.data![index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(actor.imageUrl),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Text(
                        actor.name,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: snapshot.data!.length,
          );
        },
      ),
    );
  }
}
