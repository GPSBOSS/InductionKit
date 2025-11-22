import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( //initialising Firebase (singleton)
    options: DefaultFirebaseOptions.currentPlatform,
  ); //we made sure to await the initialisation of Firebase before MyApp starts. to prevent errors.
  runApp(const MyApp());
}


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Firestore Test',
//       home: const FirestoreTestPage(),
//     );
//   }
// }

// class FirestoreTestPage extends StatefulWidget {
//   const FirestoreTestPage({super.key});

//   @override
//   State<FirestoreTestPage> createState() => _FirestoreTestPageState();
// }

// class _FirestoreTestPageState extends State<FirestoreTestPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   void _sendData() async {
//     String name = _nameController.text.trim();
//     String email = _emailController.text.trim();

//     if (name.isEmpty || email.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill in both fields")),
//       );
//       return;
//     }

//     try {
//       await _firestore.collection('testUsers').add({
//         'name': name,
//         'email': email,
//         'createdAt': DateTime.now(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Data sent to Firestore!")),
//       );

//       _nameController.clear();
//       _emailController.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Firestore Test'), backgroundColor: Colors.deepPurple),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: _sendData,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//               ),
//               child: const Text('Send to Firestore', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
