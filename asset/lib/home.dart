import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:asset/create.dart';
import 'package:asset/fetch.dart';
import 'package:asset/screens/fetch_rentals.dart';
import 'package:asset/screens/qr_display_screen.dart';
import 'package:asset/screens/qr_scanner_windows.dart';
import 'package:asset/providers/auth_provider.dart';
import 'package:asset/services/api.dart';
import 'package:asset/widgets/hover_builder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _pendingRentalCount = 0;

  final List<Widget> _screens = const [
    FetchDataScreen(),
    CreateData(),
    FetchRentalScreen(),
  ];

  final List<String> _titles = [
    'Materials',
    'Add Material',
    'Lending Requests',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _countPendingRentals());
  }
  void _countPendingRentals() async {
  try {
    final token = await Api.getToken();
    if (token == null) {
      debugPrint('No token found');
      return;
    }

    final rentals = await Api().fetchRentals(token);
    final pending = rentals.where((rental) => rental.status == 'pending').length;
    
    setState(() {
      _pendingRentalCount = pending;
    });
  } catch (e) {
    debugPrint('Failed to count pending rentals: $e');
  }
}


  


  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    
    return HoverBuilder(
      builder: (context, isHovered) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                : isHovered 
                    ? theme.colorScheme.onSurface.withOpacity(0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() => _currentIndex = index);
              Navigator.pop(context);
              if (index == 2) {
                _pendingRentalCount = 0;
              }
              _countPendingRentals();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return HoverBuilder(
      builder: (context, isHovered) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHovered 
                ? theme.colorScheme.onSurface.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: onTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  void _handleNotificationTap() {
    setState(() {
      _currentIndex = 2;
      _pendingRentalCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    
    debugPrint("🔔 Badge count: $_pendingRentalCount");
    
    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: theme.colorScheme.surface,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: theme.colorScheme.surface,
            ),
    );
    return Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(
            _titles[_currentIndex],
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primaryContainer,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: HoverBuilder(
                onTap: () {
                  _handleNotificationTap();
                  _countPendingRentals();
                },
                builder: (context, isHovered) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isHovered 
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (_pendingRentalCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: theme.colorScheme.primaryContainer,
                                width: 2,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              _pendingRentalCount > 9 ? '9+' : '$_pendingRentalCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        drawer: Drawer(
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                ),
                accountName: Text(
                  'Welcome!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  '${authProvider.user?.email ?? 'User'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    authProvider.user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.inventory_2_outlined,
                      activeIcon: Icons.inventory_2,
                      label: 'Materials',
                      index: 0,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.add_circle_outline,
                      activeIcon: Icons.add_circle,
                      label: 'Add Material',
                      index: 1,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.event_note_outlined,
                      activeIcon: Icons.event_note,
                      label: 'Lending Requests',
                      index: 2,
                    ),
                    const Divider(),
                    _buildDrawerActionItem(
                      context: context,
                      icon: Icons.qr_code,
                      label: 'Show QR Code',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QRDisplayScreen()),
                        ).then((_) => _countPendingRentals());
                      },
                    ),
                    _buildDrawerActionItem(
                      context: context,
                      icon: Icons.qr_code_scanner,
                      label: 'QR Code Scanner',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QRScannerScreen()),
                        ).then((_) => _countPendingRentals());
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceVariant,
                  child: SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: theme.textTheme.bodyLarge,
                    ),
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: theme.colorScheme.primary,
                    ),
                    value: isDarkMode,
                    onChanged: (val) {
                      authProvider.toggleTheme(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: _screens[_currentIndex],
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              height: 70,
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: theme.colorScheme.surfaceTint,
              indicatorColor: theme.colorScheme.primaryContainer,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
                _countPendingRentals();
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.inventory_2_outlined),
                  selectedIcon: const Icon(Icons.inventory_2),
                  label: 'Materials',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.add_circle_outline),
                  selectedIcon: const Icon(Icons.add_circle),
                  label: 'Add',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.event_note_outlined),
                  selectedIcon: const Icon(Icons.event_note),
                  label: 'Requests',
                ),
              ],
            ),
          ),
        ),
    );
  }
}
