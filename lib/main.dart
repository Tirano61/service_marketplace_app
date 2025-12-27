import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/upload_avatar_usecase.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  final apiClient = ApiClient();

  // Auth datasources
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient.client);
  final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);

  // Auth repository
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );

  // Auth use cases
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final uploadAvatarUseCase = UploadAvatarUseCase(authRepository);

  runApp(
    MyApp(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      uploadAvatarUseCase: uploadAvatarUseCase,
      sharedPreferences: sharedPreferences,
    ),
  );
}class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.uploadAvatarUseCase,
    required this.sharedPreferences,
  });

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;
  final SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        uploadAvatarUseCase: uploadAvatarUseCase,
      )..add(const AuthCheckRequested()), // Verificar sesión al iniciar
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.light,
        home: _RootPage(sharedPreferences: sharedPreferences),
        routes: {
          AppRoutes.onboarding: (context) => const OnboardingPage(),
          AppRoutes.login: (context) => const LoginPage(),
          AppRoutes.register: (context) => const RegisterPage(),
          AppRoutes.home: (context) => const HomePage(),
        },
      ),
    );
  }
}

/// Página raíz que maneja la navegación según el estado de auth
class _RootPage extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const _RootPage({required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navegar según estado de autenticación
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else if (state.status == AuthStatus.unauthenticated) {
          // Verificar si es primera vez con SharedPreferences
          final isFirstTime = !sharedPreferences.containsKey('user_seen_onboarding');
          if (isFirstTime) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          }
        }
      },
      child: const SplashPage(),
    );
  }
}
