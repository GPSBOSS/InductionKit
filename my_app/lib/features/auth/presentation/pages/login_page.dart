import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_repository.dart';
import '../../domain/entities/faculty.dart';
import '../../domain/entities/student_signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Repository
  final _authRepo = AuthRepository();

  // Text controllers
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final firstNameC = TextEditingController();
  final surnameC = TextEditingController();
  final otherNamesC = TextEditingController();
  final studentIdC = TextEditingController();

  bool isLogin = true;
  bool loading = false;

  // Faculties + courses
  List<Faculty> _faculties = [];
  bool _loadingFaculties = true;
  String? _facultiesError;
  Faculty? _selectedFaculty;
  String? _selectedCourse;

  @override
  void initState() {
    super.initState();
    _loadFaculties();
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    firstNameC.dispose();
    surnameC.dispose();
    otherNamesC.dispose();
    studentIdC.dispose();
    super.dispose();
  }

  // ---------- helpers ----------

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  bool _isStrongPassword(String password) {
    // At least 8 chars, 1 uppercase, 1 lowercase, 1 digit, 1 symbol
    final regex =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^\w\s]).{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> _loadFaculties() async {
    try {
      final list = await _authRepo.fetchFaculties();
      setState(() {
        _faculties = list;
        _loadingFaculties = false;
        _facultiesError = null;
      });
    } catch (e) {
      setState(() {
        _loadingFaculties = false;
        _facultiesError = 'Failed to load faculties: $e';
      });
    }
  }

  // ---------- validation for signup ----------

  bool _validateSignup(String email, String pass) {
    final firstName = firstNameC.text.trim();
    final surname = surnameC.text.trim();
    final studentId = studentIdC.text.trim();

    if (firstName.isEmpty || surname.isEmpty) {
      _showMsg('Please enter your first name and surname.');
      return false;
    }
    if (studentId.isEmpty) {
      _showMsg('Please enter your student ID.');
      return false;
    }
    if (_selectedFaculty == null) {
      _showMsg('Please select your faculty.');
      return false;
    }
    if (_selectedCourse == null) {
      _showMsg('Please select your course.');
      return false;
    }
    if (!_isStrongPassword(pass)) {
      _showMsg(
        'Password must be at least 8 characters and contain an '
        'uppercase letter, a lowercase letter, a digit, and a symbol.',
      );
      return false;
    }
    return true;
  }

  // ---------- submit ----------

  Future<void> _submit() async {
    final email = emailC.text.trim();
    final pass = passC.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showMsg('Please fill in email and password');
      return;
    }

    // Enforce UoM email format
    final emailRegex =
        RegExp(r'^[a-zA-Z]+\.[a-zA-Z]+@umail\.uom\.ac\.mu$');
    if (!emailRegex.hasMatch(email)) {
      _showMsg(
        'Use your UoM email (firstname.lastname@umail.uom.ac.mu)',
      );
      return;
    }

    if (!isLogin && !_validateSignup(email, pass)) {
      return;
    }

    setState(() => loading = true);

    try {
      UserCredential cred;

      if (isLogin) {
        // ---------- LOGIN ----------
        cred = await _authRepo.signIn(email, pass);
        final user = cred.user;
        if (user != null) {
          await _authRepo.updateLastLogin(user.uid);
        }
      } else {
        // ---------- SIGNUP ----------
        final faculty = _selectedFaculty!;
        final data = StudentSignupData(
          firstName: firstNameC.text.trim(),
          surname: surnameC.text.trim(),
          otherNames: otherNamesC.text.trim(),
          studentId: studentIdC.text.trim(),
          email: email,
          facultyName: faculty.name,
          course: _selectedCourse!,
        );

        cred = await _authRepo.signUpStudent(
          email: email,
          password: pass,
          data: data,
        );
      }

      if (mounted) context.go('/chat'); // same as before
    } on FirebaseAuthException catch (e) {
      _showMsg(e.message ?? 'Authentication error');
    } catch (e) {
      _showMsg(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Sign in' : 'Create account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailC,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'UoM email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passC,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            if (!isLogin) _buildSignupExtras(),

            FilledButton(
              onPressed: loading ? null : _submit,
              child: Text(
                loading ? 'Please wait…' : (isLogin ? 'Sign in' : 'Sign up'),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(
                isLogin
                    ? 'Create a new account'
                    : 'I already have an account',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupExtras() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: firstNameC,
                decoration: const InputDecoration(labelText: 'First name'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: surnameC,
                decoration: const InputDecoration(labelText: 'Surname'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: otherNamesC,
          decoration: const InputDecoration(
            labelText: 'Other names (optional)',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: studentIdC,
          decoration: const InputDecoration(labelText: 'Student ID'),
        ),
        const SizedBox(height: 16),

        // Faculties + courses
        if (_loadingFaculties)
          const CircularProgressIndicator()
        else if (_facultiesError != null)
          Text(
            _facultiesError!,
            style: const TextStyle(color: Colors.red),
          )
        else ...[
          DropdownButtonFormField<Faculty>(
            initialValue: _selectedFaculty,
            decoration: const InputDecoration(labelText: 'Faculty'),
            items: _faculties
                .map(
                  (f) => DropdownMenuItem(
                    value: f,
                    child: Text(f.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFaculty = value;
                _selectedCourse = null;
              });
            },
          ),
          const SizedBox(height: 12),
          if (_selectedFaculty != null)
            DropdownButtonFormField<String>(
              initialValue: _selectedCourse,
              decoration: const InputDecoration(
                labelText: 'Course / Programme',
              ),
              items: _selectedFaculty!.courses
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCourse = value);
              },
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
