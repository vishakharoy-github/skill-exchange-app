import 'package:flutter/material.dart';
import 'package:skill_exchange_app/models/user_model.dart' as app_model;
import 'package:skill_exchange_app/services/user_service.dart';
import 'package:skill_exchange_app/widgets/skill_card.dart';
import 'package:skill_exchange_app/widgets/user_card.dart';
import 'package:skill_exchange_app/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<app_model.User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await Provider.of<UserService>(context, listen: false).getAllUsers();
      setState(() {
        _users.addAll(users);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load users: ${e.toString()}';
      });
    }
  }

  void _refreshData() {
    setState(() {
      _isLoading = true;
      _users.clear();
      _errorMessage = null;
    });
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Exchange'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          if (_errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading users...')
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : IndexedStack(
        index: _currentIndex,
        children: _buildTabs(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTabs() {
    return [
      // Home Tab
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Available Skills',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                SkillCard(
                  skill: 'Web Development',
                  icon: Icons.code,
                  users: 12,
                ),
                SkillCard(
                  skill: 'UI/UX Design',
                  icon: Icons.design_services,
                  users: 8,
                ),
                SkillCard(
                  skill: 'Photography',
                  icon: Icons.camera_alt,
                  users: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'People Near You',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          ..._users.map((user) => UserCard(user: user)),
          if (_users.isEmpty)
            const Center(
              child: Text('No users found'),
            ),
        ],
      ),
      // Messages Tab
      const Center(child: Text('Messages Coming Soon')),
      // Profile Tab
      const Center(child: Text('Profile Coming Soon')),
    ];
  }
}