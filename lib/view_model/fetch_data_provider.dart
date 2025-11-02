import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:learning_cyber_security/model/subtopic_data.dart';
import 'package:learning_cyber_security/model/topic_data.dart';

class FetchDataProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TopicData> topics = [];
  bool isLoading = false;
  String error = '';

  // Constructor automatically fetches data when provider is created
  FetchDataProvider() {
    fetchAllCollections();
  }

  Future<void> fetchAllCollections() async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      print('🔍 Starting to fetch collections...');

      List<TopicData> tempCollections = [];
      List<String> knownCollections = await getCollectionNames();

      print('📚 Found ${knownCollections.length} collections: $knownCollections');

      for (String collectionName in knownCollections) {
        try {
          print('📖 Fetching documents from: $collectionName');
          List<SubtopicData> subTopic = await fetchDocumentsFromCollection(collectionName);

          print('✅ Found ${subTopic.length} documents in $collectionName');

          if (subTopic.isNotEmpty) {
            tempCollections.add(
              TopicData(
                collectionName: collectionName,
                documents: subTopic,
              ),
            );
          }
        } catch (e) {
          print('❌ Error fetching collection $collectionName: $e');
          // Don't stop - continue with other collections
        }
      }

      topics = tempCollections;
      print('✨ Total collections loaded: ${topics.length}');

      if (topics.isEmpty) {
        error = 'No data found. Please check:\n'
            '1. Firestore rules allow reading\n'
            '2. Collections have documents\n'
            '3. _metadata/collections document exists';
        print('⚠️ $error');
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('💥 Critical error in fetchAllCollections: $e');
      error = 'Failed to load data: ${e.toString()}';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> getCollectionNames() async {
    try {
      print('📋 Fetching collection names from _metadata/collections...');

      DocumentSnapshot metaDoc = await _firestore
          .collection('_metadata')
          .doc('collections')
          .get();

      if (metaDoc.exists) {
        print('✅ Metadata document found');
        Map<String, dynamic>? data = metaDoc.data() as Map<String, dynamic>?;

        if (data != null && data['names'] != null && data['names'] is List) {
          List<String> names = List<String>.from(data['names']);
          print('📋 Collection names from metadata: $names');

          if (names.isEmpty) {
            throw Exception('Metadata document exists but names array is empty');
          }

          return names;
        } else {
          throw Exception('Metadata document exists but "names" field is missing or not an array');
        }
      } else {
        throw Exception(
            'Metadata document not found!\n\n'
                'Please create it in Firestore:\n'
                '1. Collection: _metadata\n'
                '2. Document: collections\n'
                '3. Field: names (array) with your collection names'
        );
      }
    } catch (e) {
      print('❌ Error fetching collection names: $e');
      throw Exception('Cannot fetch collection names: ${e.toString()}');
    }
  }

  Future<List<SubtopicData>> fetchDocumentsFromCollection(String collectionName) async {
    try {
      print('🔍 Querying collection: $collectionName');

      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .orderBy('order')
          .get();

      print('📄 Query returned ${querySnapshot.docs.length} documents');

      List<SubtopicData> documents = [];

      for (var doc in querySnapshot.docs) {
        try {
          print('📝 Processing document: ${doc.id}');
          SubtopicData subtopic = SubtopicData.fromFirestore(doc);
          documents.add(subtopic);
          print('  ✅ Document ${doc.id} parsed successfully');
        } catch (e) {
          print('  ❌ Error parsing document ${doc.id}: $e');
          print('  📄 Document data: ${doc.data()}');
          // Continue with other documents even if one fails
        }
      }

      return documents;
    } catch (e) {
      print('❌ Error fetching documents from $collectionName: $e');
      throw Exception('Failed to fetch documents from $collectionName: $e');
    }
  }

  Future<SubtopicData?> fetchDocument(String collectionName, String documentId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (doc.exists) {
        return SubtopicData.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching document: $e');
    }
  }

  Future<List<SubtopicData>> searchDocuments(String query) async {
    List<SubtopicData> results = [];

    for (var collection in topics) {
      for (var doc in collection.documents) {
        if (doc.title.toLowerCase().contains(query.toLowerCase()) ||
            doc.key.toLowerCase().contains(query.toLowerCase())) {
          results.add(doc);
        }
      }
    }

    return results;
  }
}