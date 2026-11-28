import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../dashboard/presentation/screen/main_navigation_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/database/app_database.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(LoadUsersForLogin()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is Authenticated) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationScreen(),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selamat datang, ${state.user.name}! (${state.user.role})'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is AuthLoginFailed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
               builder: (context, state) {
                  // Jika state adalah UsersLoadedForLogin, tampilkan form
                  if (state is UsersLoadedForLogin) {
                    if (state.users.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada data user ditemukan.\nCoba restart aplikasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return LoginFormWidget(users: state.users);
                  } 
                  
                  // Jika gagal login, kita reload atau tampilkan pesan (bisa juga kita trigger load ulang atau pass list kosong kalau ada state tersimpan)
                  if (state is AuthLoginFailed) {
                    // Untuk amannya, kita kirim event load users lagi atau handle tampilannya
                    // Tapi sementara kita return widget dengan list kosong atau beri tombol retry
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(LoadUsersForLogin());
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Selama proses loading awal, tampilkan indikator
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.brown),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginFormWidget extends StatefulWidget {
  final List<User> users;
  const LoginFormWidget({super.key, required this.users});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  User? selectedUser;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.users.isNotEmpty) {
      selectedUser = widget.users.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan jika list user berubah, selectedUser ter-update jika belum ada
    if (selectedUser == null && widget.users.isNotEmpty) {
      selectedUser = widget.users.first;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.brown.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              '🍵',
              style: TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'POS TEH SOLO',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const Text(
            'Silakan pilih akun dan masukkan PIN',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Dropdown Pilih User (Sekarang di-handle lokal di StatefulWidget, dijamin bisa dipencet!)
          const Text('Pilih Pengguna:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<User>(
                value: selectedUser,
                isExpanded: true,
                items: widget.users.map((user) {
                  return DropdownMenuItem<User>(
                    value: user,
                    child: Text('${user.name} (${user.role.toUpperCase()})'),
                  );
                }).toList(),
                onChanged: (User? val) {
                  setState(() {
                    selectedUser = val;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Input PIN Angka
          const Text('PIN Keamanan (4 Digit):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Masukkan PIN',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.brown),
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Login
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E6B45),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (selectedUser == null || _pinController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pilih user dan masukkan PIN terlebih dahulu!')),
                );
                return;
              }

              // Kirim Event AttemptLogin ke AuthBloc
              context.read<AuthBloc>().add(
                    AttemptLogin(
                      userId: selectedUser!.id,
                      pin: _pinController.text.trim(),
                    ),
                  );
            },
            child: const Text(
              'MASUK APLIKASI',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Default PIN:\nOwner = 1234 | Mamak = 5678',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}