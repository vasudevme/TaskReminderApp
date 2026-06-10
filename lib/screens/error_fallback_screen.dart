import 'package:flutter/material.dart';

class ErrorFallbackScreen extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;
  final String? customMessage;

  const ErrorFallbackScreen({
    super.key, 
    this.errorDetails,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 80,
                color: Color(0xFF9068FF),
              ),
              const SizedBox(height: 24),
              Text(
                'Connection Lost',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                customMessage ?? 'We are having trouble connecting to the database. You are currently in offline mode. Some features may be unavailable.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Optional detailed error for debug
              if (errorDetails != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    errorDetails!.exceptionAsString(),
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
