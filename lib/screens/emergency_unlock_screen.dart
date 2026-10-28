import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/platform_service.dart';
import '../services/timer_service.dart';
import '../widgets/gradient_button.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

import '../providers/timer_provider.dart';

class EmergencyUnlockScreen extends HookConsumerWidget {
  const EmergencyUnlockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> _attemptUnlock() async {
      if (passwordController.text.isEmpty) {
        errorMessage.value = 'Please enter your emergency password';
        return;
      }

      isLoading.value = true;
      errorMessage.value = null;

      try {
        final success = await PlatformService.emergencyUnlock(passwordController.text);
        
        if (success) {
          // Stop the timer session
          final timerService = ref.read(timerServiceProvider);
          await timerService.stopSession(success: false);
          
          if (context.mounted) {
            // Navigate back to home screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Emergency unlock successful - Session ended'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          errorMessage.value = 'Incorrect password. Please try again.';
          passwordController.clear();
        }
      } catch (e) {
        errorMessage.value = 'Emergency unlock failed. Please try again.';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ShrexTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emergency Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: ShrexTheme.errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ShrexTheme.errorColor,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    size: 60,
                    color: ShrexTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Emergency Unlock',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: ShrexTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Enter your emergency password to unlock the device immediately.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Password Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: errorMessage.value != null 
                          ? ShrexTheme.errorColor 
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter emergency password',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onSubmitted: (_) => _attemptUnlock(),
                  ),
                ),
                const SizedBox(height: 16),

                // Error Message
                if (errorMessage.value != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ShrexTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ShrexTheme.errorColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: ShrexTheme.errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage.value!,
                            style: const TextStyle(
                              color: ShrexTheme.errorColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // Unlock Button
                GradientButton(
                  text: 'Emergency Unlock',
                  onPressed: isLoading.value ? null : _attemptUnlock,
                  isLoading: isLoading.value,
                  gradient: LinearGradient(
                    colors: [ShrexTheme.errorColor, ShrexTheme.warningColor],
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Warning
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Emergency unlock will end your focus session immediately.',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
