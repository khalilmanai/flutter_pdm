import 'package:flutter/material.dart';
import '../models/user.dart';
import '../helpers/user_role_helper.dart';
import '../services/service_locator.dart';

class UserDetailPage extends StatefulWidget {
  final User user;
  const UserDetailPage({Key? key, required this.user}) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late String _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedRole = UserRoleHelper.roleToString(widget.user.role);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ServiceLocator.userService.updateUser(
        widget.user.id,
        {
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _selectedRole,
        },
      );
      _showSnackBar('Changes saved successfully', false);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Failed to save changes', true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${widget.user.username}?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final success = await ServiceLocator.userService.deleteUser(widget.user.id);
      if (success) {
        _showSnackBar('User deleted successfully', false);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar('Failed to delete user', true);
      }
    } catch (e) {
      _showSnackBar('Error deleting user', true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.username),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: _handleSave,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              widget.user.username[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'User Profile',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_rounded),
                        ),
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Username is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_rounded),
                        ),
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Email is required';
                          }
                          if (!value!.contains('@')) {
                            return 'Invalid email format';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work_rounded),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: UserRoleHelper.roleToString(UserRole.PROJECT_MANAGER),
                            child: const Text('Project Manager'),
                          ),
                          DropdownMenuItem(
                            value: UserRoleHelper.roleToString(UserRole.MEMBER),
                            child: const Text('Member'),
                          ),
                        ],
                        onChanged: _isLoading ? null : (value) {
                          setState(() => _selectedRole = value!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isLoading ? null : _handleSave,
                icon: const Icon(Icons.save_rounded),
                label: const Text('SAVE CHANGES'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleDelete,
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('DELETE USER'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}