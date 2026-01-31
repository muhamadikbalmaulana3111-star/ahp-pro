import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import 'setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiService _apiService = ApiService();
  String _statusMessage = 'Memuat...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _statusMessage = 'Mengambil konfigurasi dari GitHub Gist...';
      });

      await Future.delayed(const Duration(seconds: 1));

      // Fetch API URL from Gist
      final baseUrl = await _apiService.fetchBaseUrl();

      setState(() {
        _statusMessage = 'Memeriksa koneksi ke server...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Check health
      final isHealthy = await _apiService.checkHealth();

      if (isHealthy) {
        setState(() {
          _statusMessage = 'Koneksi berhasil! ✓';
        });

        await Future.delayed(const Duration(seconds: 1));

        // Navigate to Setup Screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SetupScreen(apiService: _apiService),
            ),
          );
        }
      } else {
        throw Exception('Server tidak merespons');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusMessage = 'Gagal terhubung: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 40),

              // App Name
              const Text(
                'Agro-AHP Pro',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Pabrik Tepung Tapioka',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 60),

              // Loading indicator or error
              if (!_hasError)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              else
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[300],
                ),

              const SizedBox(height: 20),

              // Status message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Retry button on error
              if (_hasError)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _statusMessage = 'Memuat...';
                    });
                    _initializeApp();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),

              const Spacer(),

              // Footer
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Muhammad Ikbal Maulana\nSistem Pendukung Keputusan Pemeliharaan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
