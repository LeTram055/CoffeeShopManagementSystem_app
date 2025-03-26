import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:overlay_support/overlay_support.dart';

import 'ui/staff_barista/screens.dart';
import 'ui/auth/screens.dart';
import 'ui/staff_serve/screens.dart';
import 'services/socket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  // Khóa chế độ xoay màn hình
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Chỉ cho phép dọc đứng
  ]);

  SocketService socketService = SocketService();
  socketService.connect();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 46, 113, 230),
      secondary: Colors.red,
      surface: Colors.white,
      surfaceTint: Colors.blue[200],
      primary: const Color(0xFF0049ab),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      shadow: const Color.fromARGB(255, 12, 98, 219).withOpacity(0.9),
    );

    final themeData = ThemeData(
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shadowColor: colorScheme.shadow,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: colorScheme.primary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
        ),
        labelMedium: TextStyle(
          color: colorScheme.primary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.15,
        ),
        labelSmall: TextStyle(
          color: colorScheme.secondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.15,
        ),
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
    );

    return OverlaySupport.global(
      // Bọc ứng dụng để hỗ trợ overlay notification
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => MenuManager()),
          ChangeNotifierProvider(create: (context) => IngredientManager()),
          ChangeNotifierProvider(create: (context) => OrderManager()),
          ChangeNotifierProvider(create: (context) => AuthManager()),
          ChangeNotifierProvider(create: (context) => OrderServeManager()),
          ChangeNotifierProvider(create: (context) => PaymentManager()),
        ],
        child: Consumer<AuthManager>(builder: (ctx, authManager, child) {
          return MaterialApp(
            title: 'Hope Cafe',
            theme: themeData,
            debugShowCheckedModeBanner: false,
            home: authManager.isAuth
                ? (authManager.currentUser?.role == 'staff_barista'
                    ? const HomeBarista()
                    : const HomeServe())
                : LoginScreen(),
            routes: {
              HomeBarista.routeName: (context) => const HomeBarista(),
              MenuScreen.routeName: (context) => MenuScreen(),
              IngredientScreen.routeName: (context) => IngredientScreen(),
              ProfileScreen.routeName: (context) => ProfileScreen(),
              LoginScreen.routeName: (context) => LoginScreen(),
              TableScreen.routeName: (context) => TableScreen(),
            },
          );
        }),
      ),
    );
  }
}

class HomeBarista extends StatefulWidget {
  static const routeName = '/home';
  const HomeBarista({super.key});

  @override
  State<HomeBarista> createState() => _HomeBaristaState();
}

class _HomeBaristaState extends State<HomeBarista> {
  int _selectedIndex = 0; // Index của mục bottombar đã chọn

  final List<Widget> _pages = [
    OrderScreen(),
    MenuScreen(),
    IngredientScreen(),
    ProfileScreen(),
  ]; // Danh sách các trang

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật chỉ mục đã chọn
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Hiển thị trang dựa trên chỉ mục đã chọn
      bottomNavigationBar: BottomBar(
        // Sử dụng BottomBar
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomeServe extends StatefulWidget {
  static const routeName = '/home-serve';
  const HomeServe({super.key});

  @override
  State<HomeServe> createState() => _HomeServeState();
}

class _HomeServeState extends State<HomeServe> {
  int _selectedIndex = 0; // Index của mục bottombar đã chọn

  final List<Widget> _pages = [
    TableScreen(),
    PaidOrdersScreen(),
    ProfileScreen(),
  ]; // Danh sách các trang

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật chỉ mục đã chọn
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Hiển thị trang dựa trên chỉ mục đã chọn
      bottomNavigationBar: BottomBarStaffSerrve(
        // Sử dụng BottomBar
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
