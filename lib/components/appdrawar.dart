import 'package:chatapp/settings';
import 'package:flutter/material.dart';
import 'auth_service.dart'; // Ensure you import AuthService

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, // White background
        child: Column(
          children: [
            // Drawer Header with Welcome Message
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 23, 23, 23), // Black header background
              ),
              child: Center(
                child: const Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.white, // White text for the header
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Home Tile
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black),
              title: const Text('Home', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),

            // Settings Tile
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: const Text('Settings', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()), // Navigate to SettingsPage
                );
              },
            ),

            // Logout Tile
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text('Logout', style: TextStyle(color: Colors.black)),
              onTap: () {
                // Call AuthService to sign out
                AuthService().signOut().then((_) {
                  Navigator.pushReplacementNamed(context, '/'); // Go back to Login
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sign out failed: $error')),
                  );
                });
              },
            ),

            const Spacer(), // Push items to the top
            // Footer with version or copyright
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'App Version 1.0',
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
