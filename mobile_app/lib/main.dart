import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'screens/splash/splash_screen.dart';
import 'services/theme_manager.dart';
import 'config/app_constants.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    
   EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('si')], 
      
      path: 'assets/translations', 
     
      fallbackLocale: const Locale('en'), 
      
      child: const EFineApp(),
    ),
  );
}

class EFineApp extends StatelessWidget {
  const EFineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'e-Fine SL',
          debugShowCheckedModeBanner: false,
         
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale, 
          
          themeMode: mode,
          theme: ThemeData(
            primaryColor: AppColors.primaryGreenDark,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen, primary: AppColors.primaryGreenDark),
            useMaterial3: true,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: AppColors.background,
            cardColor: AppColors.cardWhite,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryGreenDark,
              foregroundColor: Colors.white,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: AppColors.primaryGreenDark,
              unselectedItemColor: Colors.grey,
              backgroundColor: AppColors.cardWhite,
              elevation: 10,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
             primaryColor: AppColors.primaryGreenDark,
             scaffoldBackgroundColor: const Color(0xFF121212),
             cardColor: const Color(0xFF1E1E1E),
             colorScheme: ColorScheme.dark(
               primary: AppColors.primaryGreenDark, 
               secondary: AppColors.primaryGreenLight,
               surface: const Color(0xFF1E1E1E),
             ),
             appBarTheme: const AppBarTheme(
               backgroundColor: AppColors.primaryGreenDark,
               foregroundColor: Colors.white,
             ),
             bottomNavigationBarTheme: const BottomNavigationBarThemeData(
               selectedItemColor: AppColors.primaryGreenLight,
               unselectedItemColor: Colors.grey,
               backgroundColor: Color(0xFF1E1E1E),
               elevation: 0,
             ),
             textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
          ),
          home: const SplashScreen(),
        );
      }
    );
  }
}