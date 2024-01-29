import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Authentication Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> addUser(String email, String password, String role) async {
    try {
      await usersCollection.add({
        'email': email,
        'password': password,
        'role': role,
      });
      print('User added successfully');
    } catch (error) {
      print('Error adding user: $error');
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final QuerySnapshot querySnapshot = await usersCollection
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        print('Invalid credentials');
        return null;
      }
    } catch (error) {
      print('Error during login: $error');
      return null;
    }
  }

  bool isAdmin(Map<String, dynamic>? user) {
    return user != null && user['role'] == 'Admin';
  }

  Future<void> performAdminActions(Map<String, dynamic>? user) async {
    if (isAdmin(user)) {
      // Admin can add, update, and delete all users
      print('Admin actions: add, update, delete users');
      await addUser('newuser@example.com', 'newpassword', 'Employee');
    } else {
      // Non-admin can view all users
      print('Non-admin actions: view users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Authentication Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: roleController,
              decoration: InputDecoration(labelText: 'Role'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await addUser(
                  emailController.text,
                  passwordController.text,
                  roleController.text,
                );
              },
              child: Text('Add User'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = await login(
                  emailController.text,
                  passwordController.text,
                );
                await performAdminActions(user);
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
