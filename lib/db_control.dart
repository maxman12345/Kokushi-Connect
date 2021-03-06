import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

abstract class Database {
  //user getters 
  Future<String> getFirstName(String userId);
  Future<String> getLastName(String userId);
  Future<String> getNickname(String userId);
  Future<String> getEmail(String userId);
  Future<DateTime> getDOB(String userId);
  Future<String> getRank(String userId);
  Future<String> getDescription(String userId);
  Future<String> getDojoIdByUserId(String userId);
  Future<String> getAccountType(String userId);
  Future<String> getUserDojo(String userId);

  //user setters
  Future<void> setFirstName(String firstName, String userId);
  Future<void> setLastName(String lastName, String userId);
  Future<void> setNickname(String nickname, String userId);
  Future<void> setEmail(String email, String userId);
  Future<void> setDOB(DateTime dob, String userId);
  Future<void> setRank(String rank, String userId);
  Future<void> setDescription(String description, String userId);
  Future<void> setDojoIdForUser(String dojoId, String userId);
  Future<void> setAccountType(String accountType, String userId);
  Future<void> setUserDojo(String dojoId, String userId);

  //create
  Future<void> createDojo(String dojoName, String address, String dojoCode);
  Future<void> createEvent(DateTime startDate, DateTime endDate, String title, String description, String userId, String dojoId, String classId, [bool trackAttendance]);
  Future<void> createAccount(String firstName, String lastName, String nickname, DateTime dob, String rank, String accountType, String description, String userId); //creates a new account
  Future<String> createClass (String name, String description, String userId, String dojoId);

  //dojo getters
  Future<String> getDojoName(String dojoId);
  Future<String> getDojoCode(String dojoId);
  Future<String> getDojoAddress(String dojoId);
  Future<String> getDojoIdByDojoCode(String dojoCode);
  //Future<DocumentSnapshot> getAllUsersByDojoId(String dojoId);

  //dojo setters
  Future<void> setDojoCode(String code, String dojoId);
  Future<void> setDojoName(String name, String dojoId);
  Future<void> setDojoAddress(String address, String dojoId);
  Future<void> addMemberToDojo(String userId, String dojoId);

  //event getters
  Future<String> getEventTitle (String eventId);
  Future<String> getEventDescription (String eventId);
  Future<String> getUserIdForEvent (String eventId);
  Future<String> getDojoIdForEvent (String eventId);
  Future<DateTime> getEventDate (String eventId);

}

class Db implements Database {
  final Firestore _firestore = Firestore.instance;

  //gets all of one users information
  Future<DocumentSnapshot> userInfo(String userId) async {
    return _firestore.collection('users').document(userId).get();
  }

  //getters for user
  Future<String> getFirstName(String userId) async {
    DocumentSnapshot document = await userInfo(userId);
    return document.data['firstName'];
  }

  Future<String> getLastName(String userId) async {
    DocumentSnapshot document = await userInfo(userId);
    return document.data['lastName'];
  }

  Future<String> getNickname(String userId) async {
    DocumentSnapshot document = await userInfo(userId);
    return document.data['nickname'];
  }

  Future<String> getEmail(String userId) async {
    DocumentSnapshot document = await userInfo(userId);
    return document.data['email'];
  }
  
  Future<DateTime> getDOB(String userId) async {
    DocumentSnapshot document = await userInfo(userId);
    return document.data['dob'];
  }

  Future<String> getRank(String userId) async {
    DocumentSnapshot document = await userInfo(userId);
    return document.data['rank'];
  }

  Future<String> getDescription(String userId) async {
    DocumentSnapshot document = await userInfo(userId);
    return document.data['description'];
  }

  Future<String> getDojoIdByUserId(String userId) async {
    DocumentSnapshot document = await userInfo(userId);
    return document.data['dojoId'];
  }

  Future<String> getAccountType(String userId) async {
    DocumentSnapshot document = await userInfo(userId);
    return document.data['accountType'];
  }

  Future<String> getUserDojo(String userId) async {
    DocumentSnapshot document = await userInfo(userId);
    return document.data['dojoId'];
  }

  //setters for users
  Future<void> setFirstName(String firstName, String userId) async {
    return _firestore.collection("users").document(userId).updateData({ 'firstName': firstName});
  }

  Future<void> setLastName(String lastName, String userId) async {
    return _firestore.collection("users").document(userId).updateData({ 'lastName': lastName});
  }

  Future<void> setNickname(String nickname, String userId) async {
    return _firestore.collection("users").document(userId).updateData({ 'nickname': nickname});
  }

  Future<void> setEmail(String email, String userId) async {
    return _firestore.collection("users").document(userId).updateData({ 'email': email});
  }

  Future<void> setDOB(DateTime dob, String userId) async{
    return _firestore.collection("users").document(userId).updateData({ 'dob': dob});
  }

  Future<void> setRank(String rank, String userId) async {
    return _firestore.collection("users").document(userId).updateData({ 'rank': rank});
  }

  Future<void> setDescription(String description, String userId) async {
    return _firestore.collection("users").document(userId).updateData({ 'description': description});
  }

  Future<void> setDojoIdForUser(String dojoId, String userId) async {
    return _firestore.collection("users").document(userId).updateData({ 'dojoId': dojoId});
  }

  Future<void> setAccountType(String accountType, String userId){
    return _firestore.collection("users").document(userId).updateData({ 'accountType': accountType});
  }

  Future<void> setUserDojo(String dojoId, String userId) async {
    await addMemberToDojo(userId, dojoId);
    return _firestore.collection("users").document(userId).updateData({ 'dojoId': dojoId });
  }

  //account and dojo creation
  Future<void> createAccount(String firstName, String lastName, String nickname, DateTime dob, String rank, String accountType, String description, String userId) async {
    return _firestore.collection("users").document(userId).setData({ 'firstName': firstName, 'lastName': lastName, 'nickname': nickname, 'dob': dob, 'rank': rank, 'accountType': accountType, 'description': description, 'dojoId': null });
  }

  Future<String> createDojo(String dojoName, String address, String dojoCode) async {
    _firestore.collection("dojos").document().setData({'dojoName' : dojoName, 'address' : address, 'dojoCode' : dojoCode});
    String dojoId = await getDojoIdByDojoCode(dojoCode);
    return dojoId;
  }

  Future<void> createEvent(DateTime startDate, DateTime endDate, String title, String description, String userId, String dojoId, String classId, [bool trackAttendance = true]) async {
    String eventId = _firestore.collection("events").document().documentID;
    if (classId != null) {
      addEventToClass(eventId, classId);
    }
    if (trackAttendance) {
      return _firestore.collection("events").document(eventId).setData({'startDate': startDate, 'endDate': endDate, 'title': title, 'description': description, 'userId': userId, 'dojoId': dojoId, "classId": classId, "attendance": new Map()});
    }
    else {
  return _firestore.collection("events").document(eventId).setData({'startDate': startDate, 'endDate': endDate, 'title': title, 'description': description, 'userId': userId, 'dojoId': dojoId, "classId": classId});
    }
  }

  Future<String> createClass (String name, String description, String userId, String dojoId) async {
    String id = await _firestore.collection("classes").document().documentID;
    _firestore.collection("classes").document(id).setData({"name": name, "description": description, "dojoId": dojoId, "instructor": userId});
    return id;
  }

  //gets all dojo information
  Future<DocumentSnapshot> dojoInfo(String dojoId) async {
    return _firestore.collection('dojos').document(dojoId).get();
  }

  //getters for dojo
  Future<String> getDojoName([String dojoId]) async {
    DocumentSnapshot document = await dojoInfo(dojoId);
    return document.data['dojoName'];
  }

  Future<String> getDojoCode(String dojoId) async {
    DocumentSnapshot document = await dojoInfo(dojoId);
    return document.data['dojoCode'];
  }

  Future<String> getDojoAddress(String dojoId) async {
    DocumentSnapshot document = await dojoInfo(dojoId);
    return document.data['address'];
  }
  
  Future<String> getDojoIdByDojoCode(String dojoCode) async {
    try {
      QuerySnapshot documents = await _firestore.collection('dojos').where(
          'dojoCode', isEqualTo: dojoCode).getDocuments();
      return documents.documents.first.documentID;
    } catch (e) {
      return null;
    }
  }

  //setters for dojo
  Future<void> setDojoCode(String code, String dojoId) async {
    return _firestore.collection("dojos").document(dojoId).updateData({ 'dojoCode': code});
  }
  Future<void> setDojoName(String name, String dojoId) async {
    return _firestore.collection("dojos").document(dojoId).updateData({ 'dojoName': name});
  }
  Future<void> setDojoAddress(String address, String dojoId) async {
    return _firestore.collection("dojos").document(dojoId).updateData({ 'address': address});
  }

  Future<void> addMemberToDojo(String userId, String dojoId) {
    return _firestore.collection("dojos").document(dojoId).collection("members").add({ userId : true });
  }

  Future<void> addEventToClass(String eventId, String classId) {
  return _firestore.collection("classes").document(classId).collection("events").add({ eventId : true });
  }

  //getters for event
  Future<String> getEventTitle (String eventId) async {
    DocumentSnapshot document = await userInfo(eventId);
    return document.data['title'];
  }

  Future<String> getEventDescription (String eventId) async {
    DocumentSnapshot document = await userInfo(eventId);
    return document.data['description'];
  }

  Future<String> getUserIdForEvent (String eventId) async {
    DocumentSnapshot document = await userInfo(eventId);
    return document.data['userId'];
  }

  Future<String> getDojoIdForEvent (String eventId) async {
    DocumentSnapshot document = await userInfo(eventId);
    return document.data['dojoId'];
  }

  Future<DateTime> getEventDate (String eventId) async {
    DocumentSnapshot document = await userInfo(eventId);
    return document.data['date'];
  }

}