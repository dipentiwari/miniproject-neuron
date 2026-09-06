import 'package:flutter/material.dart';

void main() {
  runApp(const NeuronApp());
}

class NeuronApp extends StatefulWidget {
  const NeuronApp({super.key});

  @override
  State<NeuronApp> createState() => _NeuronAppState();
}

class _NeuronAppState extends State<NeuronApp> {
  // Dark theme is the default
  bool isDarkMode = true;
  bool isLoggedIn = false;
  String currentUser = 'Ishi Sharma';

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void handleLogin(String user) {
    setState(() {
      currentUser = user.isNotEmpty ? user : 'Ishi Sharma';
      isLoggedIn = true;
    });
  }

  void handleLogout() {
    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neuron - Your Second Brain',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardColor: Colors.white,
        primaryColor: const Color(0xFF7C3AED),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF7C3AED),
          surface: Colors.white,
          onSurface: Color(0xFF1F2937),
          outline: Color(0xFFE2E8F0),
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F17),
        cardColor: const Color(0xFF151B26),
        primaryColor: const Color(0xFF8B5CF6),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          surface: Color(0xFF151B26),
          onSurface: Color(0xFFF3F4F6),
          outline: Color(0xFF232B3A),
        ),
        fontFamily: 'Roboto',
      ),
      home: isLoggedIn
          ? NeuronDashboard(
              userName: currentUser,
              isDarkMode: isDarkMode,
              onToggleTheme: toggleTheme,
              onLogout: handleLogout,
            )
          : NeuronAuthPage(
              isDarkMode: isDarkMode,
              onToggleTheme: toggleTheme,
              onLoginSuccess: handleLogin,
            ),
    );
  }
}

// -------------------------------------------------------------
// AUTHENTICATION (LOGIN / SIGN UP) PAGE
// -------------------------------------------------------------
class NeuronAuthPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final ValueChanged<String> onLoginSuccess;

  const NeuronAuthPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onLoginSuccess,
  });

  @override
  State<NeuronAuthPage> createState() => _NeuronAuthPageState();
}

class _NeuronAuthPageState extends State<NeuronAuthPage> {
  bool isSignUp = false; // Toggle between Login ("Welcome back 👋") and Sign Up ("Create your account")
  bool rememberMe = true;
  bool agreeTerms = false;
  bool agreePrivacy = false;
  bool obscurePassword = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showNotification(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleSubmit() {
    if (isSignUp) {
      if (_nameController.text.trim().isEmpty) {
        _showNotification('Please enter your full name');
        return;
      }
      if (_emailController.text.trim().isEmpty) {
        _showNotification('Please enter your email');
        return;
      }
      if (_passwordController.text.trim().isEmpty) {
        _showNotification('Please enter a password');
        return;
      }
      if (!agreeTerms || !agreePrivacy) {
        _showNotification('Please accept the Terms and Privacy Policy');
        return;
      }
      widget.onLoginSuccess(_nameController.text.trim());
    } else {
      if (_emailController.text.trim().isEmpty) {
        _showNotification('Please enter your email address');
        return;
      }
      if (_passwordController.text.trim().isEmpty) {
        _showNotification('Please enter your password');
        return;
      }
      final displayName = _emailController.text.split('@').first;
      widget.onLoginSuccess(displayName.isNotEmpty ? displayName : 'Ishi Sharma');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgCardColor = isDark ? const Color(0xFF131926) : Colors.white;
    final borderColor = isDark ? const Color(0xFF222B3D) : const Color(0xFFE2E8F0);
    final fieldFillColor = isDark ? const Color(0xFF0F141F) : const Color(0xFFF8FAFC);
    final primaryPurple = const Color(0xFF7C3AED);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F17) : const Color(0xFFF4F6F9),
      body: Stack(
        children: [
          // Top Corner Theme Toggle Button & Switcher
          Positioned(
            top: 24,
            right: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDark ? 'DARK THEME' : 'LIGHT THEME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1F293D) : Colors.white,
                    foregroundColor: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                    elevation: isDark ? 0 : 2,
                    shadowColor: Colors.black12,
                  ),
                  onPressed: widget.onToggleTheme,
                  icon: Icon(
                    isDark ? Icons.mode_night_outlined : Icons.wb_sunny_outlined,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Central Login / Register Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 38),
                  decoration: BoxDecoration(
                    color: bgCardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.45 : 0.06),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Brain Logo
                      Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.35),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.psychology_alt_outlined,
                            size: 54,
                            color: Color(0xFFA78BFA),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Neuron',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Text(
                          'Your Second Brain',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Title & Subtitle
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isSignUp ? 'Create your account' : 'Welcome back',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            if (!isSignUp) ...[
                              const SizedBox(width: 6),
                              const Text('👋', style: TextStyle(fontSize: 18)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          isSignUp
                              ? 'Start your journey with Neuron.'
                              : 'Login to continue to Neuron.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Fields
                      if (isSignUp) ...[
                        _buildInputField(
                          controller: _nameController,
                          hint: 'Full Name',
                          icon: Icons.person_outline_rounded,
                          isDark: isDark,
                          fillColor: fieldFillColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 14),
                      ],

                      _buildInputField(
                        controller: _emailController,
                        hint: 'Email address',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                        fillColor: fieldFillColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 14),

                      _buildInputField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        obscureText: obscurePassword,
                        onToggleObscure: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        isDark: isDark,
                        fillColor: fieldFillColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 12),

                      // Checkboxes / Options
                      if (!isSignUp)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: rememberMe,
                                    activeColor: primaryPurple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        rememberMe = val ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Remember me',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => _showNotification('Password reset email sent!'),
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8B5CF6),
                                ),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildTermsCheckbox(
                          label: 'I agree to the Terms of Service',
                          value: agreeTerms,
                          onChanged: (val) => setState(() => agreeTerms = val ?? false),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 6),
                        _buildTermsCheckbox(
                          label: 'I agree to the Privacy Policy',
                          value: agreePrivacy,
                          onChanged: (val) => setState(() => agreePrivacy = val ?? false),
                          isDark: isDark,
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Gradient Submit Button
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isSignUp ? 'Create Account' : 'Login',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Divider "or continue with"
                      Row(
                        children: [
                          Expanded(child: Divider(color: borderColor, thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: borderColor, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Social Buttons: Google & GitHub
                      _buildSocialButton(
                        text: 'Continue with Google',
                        iconWidget: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/480px-Google_%22G%22_logo.svg.png',
                          width: 16,
                          height: 16,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.g_mobiledata, color: Colors.red, size: 20),
                        ),
                        onTap: () {
                          _showNotification('Logging in with Google...');
                          widget.onLoginSuccess('Ishi Sharma');
                        },
                        isDark: isDark,
                        borderColor: borderColor,
                        fillColor: fieldFillColor,
                      ),
                      const SizedBox(height: 10),
                      _buildSocialButton(
                        text: 'Continue with GitHub',
                        iconWidget: Icon(
                          Icons.code_rounded,
                          size: 18,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onTap: () {
                          _showNotification('Logging in with GitHub...');
                          widget.onLoginSuccess('Ishi Sharma');
                        },
                        isDark: isDark,
                        borderColor: borderColor,
                        fillColor: fieldFillColor,
                      ),
                      const SizedBox(height: 22),

                      // Bottom toggle between Login and Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSignUp
                                ? 'Already have an account? '
                                : "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isSignUp = !isSignUp;
                              });
                            },
                            child: Text(
                              isSignUp ? 'Log in' : 'Sign up',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
    required Color fillColor,
    required Color borderColor,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 16,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            fontSize: 13,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            activeColor: const Color(0xFF8B5CF6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String text,
    required Widget iconWidget,
    required VoidCallback onTap,
    required bool isDark,
    required Color borderColor,
    required Color fillColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// DASHBOARD (LANDING) PAGE
// -------------------------------------------------------------
class NeuronDashboard extends StatefulWidget {
  final String userName;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const NeuronDashboard({
    super.key,
    required this.userName,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onLogout,
  });

  @override
  State<NeuronDashboard> createState() => _NeuronDashboardState();
}

class _NeuronDashboardState extends State<NeuronDashboard> {
  String selectedNavItem = 'Home';
  String selectedWorkspace = 'Personal';
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> navItems = [
    'Home',
    'Chat',
    'Knowledge',
    'Connections',
    'Timeline',
    'Reflection',
    'Tasks',
    'Settings',
  ];

  final Map<String, IconData> navIcons = {
    'Home': Icons.home_rounded,
    'Chat': Icons.chat_bubble_outline_rounded,
    'Knowledge': Icons.menu_book_rounded,
    'Connections': Icons.hub_outlined,
    'Timeline': Icons.timeline_rounded,
    'Reflection': Icons.history_rounded,
    'Tasks': Icons.check_box_outlined,
    'Settings': Icons.settings_outlined,
  };

  final List<Map<String, dynamic>> workspaces = [
    {'name': 'Personal', 'color': const Color(0xFF8B5CF6), 'badge': 'P'},
    {'name': 'College', 'color': const Color(0xFF10B981), 'badge': 'C'},
    {'name': 'Projects', 'color': const Color(0xFFF59E0B), 'badge': 'P'},
    {'name': 'Research', 'color': const Color(0xFF3B82F6), 'badge': 'R'},
  ];

  final List<Map<String, dynamic>> scheduleItems = [
    {
      'time': '09:00 AM',
      'title': 'Data Structures Class',
      'location': 'CS Building, Room 203',
      'accent': const Color(0xFF6366F1),
    },
    {
      'time': '11:00 AM',
      'title': 'Project Meeting',
      'location': 'Online (Google Meet)',
      'accent': const Color(0xFF3B82F6),
    },
    {
      'time': '02:00 PM',
      'title': 'Interview Preparation',
      'location': 'Personal Workspace',
      'accent': const Color(0xFFF97316),
    },
    {
      'time': '04:00 PM',
      'title': 'DSA Practice',
      'location': 'LeetCode 150',
      'accent': const Color(0xFF10B981),
    },
  ];

  final List<Map<String, dynamic>> quickPrompts = [
    {
      'icon': Icons.calendar_today_rounded,
      'color': const Color(0xFF8B5CF6),
      'text': 'What did I work on last week?',
    },
    {
      'icon': Icons.mail_outline_rounded,
      'color': const Color(0xFFEF4444),
      'text': 'Summarize unread emails',
    },
    {
      'icon': Icons.description_outlined,
      'color': const Color(0xFF3B82F6),
      'text': 'Show my recent documents',
    },
    {
      'icon': Icons.event_note_rounded,
      'color': const Color(0xFF8B5CF6),
      'text': "What's on my schedule today?",
    },
  ];

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitPrompt() {
    final query = _promptController.text.trim();
    if (query.isNotEmpty) {
      _showNotification('Sent to Neuron: "$query"');
      _promptController.clear();
    }
  }

  void _addWorkspaceDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Workspace'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Workspace Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  workspaces.add({
                    'name': nameController.text.trim(),
                    'color': const Color(0xFFEC4899),
                    'badge': nameController.text.trim()[0].toUpperCase(),
                  });
                });
                Navigator.pop(ctx);
                _showNotification('Added workspace: ${nameController.text.trim()}');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final theme = Theme.of(context);
    final borderColor = isDark ? const Color(0xFF22272E) : const Color(0xFFE5E7EB);
    final sidebarBg = isDark ? const Color(0xFF10141B) : Colors.white;

    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: sidebarBg,
              border: Border(right: BorderSide(color: borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo / Title
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 20),
                  child: Row(
                    children: [
                      _buildGlowingBrainIcon(size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Neuron',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Your Second Brain',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Nav items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      ...navItems.map((item) {
                        final isSelected = selectedNavItem == item;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF261E3E)
                                    : const Color(0xFFEDE9FE))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            dense: true,
                            horizontalTitleGap: 10,
                            leading: Icon(
                              navIcons[item],
                              size: 20,
                              color: isSelected
                                  ? theme.primaryColor
                                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                            title: Text(
                              item,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? (isDark ? Colors.white : theme.primaryColor)
                                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selectedNavItem = item;
                              });
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Workspaces Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Workspaces',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: _addWorkspaceDialog,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Workspaces List
                      ...workspaces.map((ws) {
                        final isSelected = selectedWorkspace == ws['name'];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF261E3E)
                                    : const Color(0xFFEDE9FE))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            dense: true,
                            horizontalTitleGap: 10,
                            leading: CircleAvatar(
                              radius: 10,
                              backgroundColor: ws['color'] as Color,
                              child: Text(
                                ws['badge'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              ws['name'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? (isDark ? Colors.white : theme.primaryColor)
                                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selectedWorkspace = ws['name'] as String;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // User Profile bottom section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            isDark ? const Color(0xFF2D333B) : const Color(0xFFE2E8F0),
                        child: Text(
                          widget.userName.isNotEmpty
                              ? widget.userName[0].toUpperCase()
                              : 'I',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Premium Plan',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                        onSelected: (val) {
                          if (val == 'logout') {
                            widget.onLogout();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, size: 18),
                                SizedBox(width: 8),
                                Text('Profile'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Log out', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Center View
          Expanded(
            child: Column(
              children: [
                // Top Search & Actions Bar with Theme Toggle Button
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : Colors.white,
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF161B22) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                size: 18,
                                color: isDark ? Colors.grey[400] : Colors.grey[500],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search or ask Neuron anything...',
                                    hintStyle: TextStyle(
                                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                                      fontSize: 13,
                                    ),
                                    isDense: true,
                                  ),
                                  onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) {
                                      _showNotification('Searching: "$val"');
                                    }
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF22272E) : const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '⌘ K',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Notifications Button
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, size: 20),
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        tooltip: 'Notifications',
                        onPressed: () => _showNotification('No new notifications'),
                      ),

                      // Top Corner Theme Toggle Button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isDark ? Icons.mode_night_outlined : Icons.wb_sunny_outlined,
                              size: 20,
                            ),
                            color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                            onPressed: widget.onToggleTheme,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),
                            _buildGlowingBrainIcon(size: 64),
                            const SizedBox(height: 16),
                            Text(
                              'Good morning, ${widget.userName}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'How can I help you today?',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Ask Neuron Input Box
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF161B22) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _promptController,
                                    maxLines: 3,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Ask Neuron anything...',
                                      hintStyle: TextStyle(
                                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                    onSubmitted: (_) => _submitPrompt(),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.attach_file_rounded, size: 20),
                                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                                        tooltip: 'Attach file',
                                        onPressed: () => _showNotification('Attach file clicked'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.mic_none_rounded, size: 20),
                                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                                        tooltip: 'Voice input',
                                        onPressed: () => _showNotification('Listening via microphone...'),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: _submitPrompt,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: theme.primaryColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.near_me_rounded,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Today's Schedule Card
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF161B22) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: (isDark
                                                      ? const Color(0xFF8B5CF6)
                                                      : const Color(0xFFEDE9FE))
                                                  .withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.calendar_month_outlined,
                                              size: 18,
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Today's Schedule",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () => _showNotification('Opening Calendar...'),
                                        child: Row(
                                          children: [
                                            Text(
                                              'View Calendar',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.open_in_new,
                                              size: 14,
                                              color: theme.primaryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: scheduleItems.map((item) {
                                      return Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          padding: const EdgeInsets.only(left: 10),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: item['accent'] as Color,
                                                width: 2.5,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['time'] as String,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item['title'] as String,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? Colors.white : Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item['location'] as String,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Quick Action Prompt Cards
                            ...quickPrompts.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: (item['color'] as Color).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      item['icon'] as IconData,
                                      size: 16,
                                      color: item['color'] as Color,
                                    ),
                                  ),
                                  title: Text(
                                    item['text'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.grey[200] : Colors.grey[800],
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _promptController.text = item['text'] as String;
                                    });
                                    _submitPrompt();
                                  },
                                ),
                              );
                            }),
                            const SizedBox(height: 24),

                            // Footer: Neuron can search connected sources
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Neuron can search your connected sources',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _buildSourceBadge(Icons.drive_folder_upload, const Color(0xFF34A853), 'Google Drive'),
                                const SizedBox(width: 6),
                                _buildSourceBadge(Icons.mail, const Color(0xFFEA4335), 'Gmail'),
                                const SizedBox(width: 6),
                                _buildSourceBadge(Icons.code, const Color(0xFF6B7280), 'GitHub'),
                                const SizedBox(width: 6),
                                _buildSourceBadge(Icons.note_alt, const Color(0xFF3B82F6), 'Notion'),
                                const SizedBox(width: 6),
                                Text(
                                  '+3',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingBrainIcon({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.35),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.psychology_alt_outlined,
        size: size,
        color: const Color(0xFFA78BFA),
      ),
    );
  }

  Widget _buildSourceBadge(IconData icon, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => _showNotification('Connected source: $tooltip'),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}
