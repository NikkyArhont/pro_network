import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum StartRoute { onboarding, authChoice, home }

class AppStartService {
  Future<StartRoute> determineStartRoute() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    
    if (isFirstLaunch) {
      return StartRoute.onboarding;
    }
    
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return StartRoute.authChoice;
    } else {
      return StartRoute.home;
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
  }
}

