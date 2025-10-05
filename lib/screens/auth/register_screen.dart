import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String password = '';
    String? phone;
    String? company;

    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create an account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      onChanged: (v) => name = v,
                      validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (v) => email = v,
                      validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onChanged: (v) => password = v,
                      validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Phone (optional)'),
                      onChanged: (v) => phone = v,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Company (optional)'),
                      onChanged: (v) => company = v,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final ok = await context.read<AuthProvider>().register(
                                name: name,
                                email: email,
                                password: password,
                                company: company,
                                phone: phone,
                              );
                          if (ok && context.mounted) {
                            context.go('/customer/home');
                          }
                        },
                        child: Consumer<AuthProvider>(
                          builder: (context, auth, child) => Text(auth.isLoading ? 'Creating...' : 'Sign Up'),
                        ),
                      ),
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) => auth.error == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
