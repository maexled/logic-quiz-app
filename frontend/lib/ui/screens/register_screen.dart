import 'package:flutter/material.dart';
import 'package:formal_logic_quiz_app/routing/router.dart';
import 'package:formal_logic_quiz_app/services/authentication/token_authentication.dart';
import 'package:formal_logic_quiz_app/ui/widgets/page_header.dart';
import 'package:formal_logic_quiz_app/ui/widgets/text_with_link.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var username = '';
  var email = '';
  var password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextWithLink(
                onTap: () => {context.go(loginScreen)},
                text: "Already have an account? Login",
                tapText: "here")),
      ),
      body: SafeArea(
        child: ListView(children: [
          const PageHeader(
            title: "Register",
            subtitle: "Register for a new account",
          ),
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail),
                        labelText: 'E-Mail',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        username = value;
                      });
                    },
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: 'Username',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Password',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () async {
                      final (success, errorMessage) =
                          await register(email, username, password);
                      if (success) {
                        context.go(loginScreen);
                        toastification.show(
                          context: context,
                          type: ToastificationType.success,
                          title: const Text('Register successful'),
                          description: const Text('You can now login'),
                          autoCloseDuration: const Duration(seconds: 5),
                        );
                      } else {
                        toastification.show(
                          context: context,
                          type: ToastificationType.error,
                          title: const Text('Register failed'),
                          description: Text(errorMessage),
                          autoCloseDuration: const Duration(seconds: 5),
                        );
                      }
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
