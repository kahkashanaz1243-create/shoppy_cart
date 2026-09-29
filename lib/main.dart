
import 'package:flutter/material.dart';

void main() {
  runApp(const AddressBookApp());
}

class Contact {
  String name;
  String phone;
  String secondPhone;
  String email;
  String address;
  String birthday;
  String notes;
  bool favorite;
  String group;

  Contact({
    required this.name,
    required this.phone,
    this.secondPhone = '',
    this.email = '',
    this.address = '',
    this.birthday = '',
    this.notes = '',
    this.favorite = false,
    this.group = '',
  });
}

class ContactStore extends ChangeNotifier {
  final List<Contact> contacts = [
    Contact(
      name: 'Gayyur Abbasi',
      phone: '+91 98765 43210',
      favorite: true,
      group: 'Family',
    ),
    Contact(
      name: 'Mohammad Ahmed',
      phone: '+91 98765 12345',
      group: 'Friends',
    ),
    Contact(
      name: 'Rahul Kumar',
      phone: '+91 98765 67890',
      group: 'Work',
    ),
  ];

  final List<String> groups = ['Family', 'Friends', 'Work'];

  void addContact(Contact c) {
    contacts.add(c);
    notifyListeners();
  }

  void updateContact(int index, Contact c) {
    contacts[index] = c;
    notifyListeners();
  }

  void deleteContact(int index) {
    contacts.removeAt(index);
    notifyListeners();
  }

  void toggleFavorite(Contact c) {
    c.favorite = !c.favorite;
    notifyListeners();
  }

  void addGroup(String name) {
    if (name.trim().isNotEmpty && !groups.contains(name.trim())) {
      groups.add(name.trim());
      notifyListeners();
    }
  }
}

final store = ContactStore();

class AddressBookApp extends StatefulWidget {
  const AddressBookApp({super.key});

  @override
  State<AddressBookApp> createState() => _AddressBookAppState();
}

class _AddressBookAppState extends State<AddressBookApp> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Address Book',
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5262C9)),
            scaffoldBackgroundColor: const Color(0xFFF5F6FB),
            cardTheme: const CardThemeData(
              elevation: 0,
              margin: EdgeInsets.zero,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7986E8),
              brightness: Brightness.dark,
            ),
          ),
          home: HomePage(
            onDarkModeChanged: (value) => setState(() => darkMode = value),
            darkMode: darkMode,
          ),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const HomePage({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Address Book',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    darkMode: darkMode,
                    onDarkModeChanged: onDarkModeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomBar(current: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openAddContact(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Contact'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            SearchBox(onTap: () => openSearch(context)),
            const SizedBox(height: 26),
            const Text(
              'Quick Access',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.18,
              children: [
                QuickCard(
                  icon: Icons.people_alt_outlined,
                  title: 'All Contacts',
                  value: '${store.contacts.length}',
                  onTap: () => openContacts(context),
                ),
                QuickCard(
                  icon: Icons.star_border,
                  title: 'Favorites',
                  value: '${store.contacts.where((c) => c.favorite).length}',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesPage()),
                  ),
                ),
                QuickCard(
                  icon: Icons.folder_outlined,
                  title: 'Groups',
                  value: '${store.groups.length}',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GroupsPage()),
                  ),
                ),
                QuickCard(
                  icon: Icons.person_add_alt_1,
                  title: 'Add Contact',
                  value: '+',
                  onTap: () => openAddContact(context),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Contacts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () => openContacts(context),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...store.contacts.take(5).toList().asMap().entries.map(
              (e) => ContactTile(
                contact: e.value,
                onTap: () => openDetails(context, e.value),
                onFavorite: () => store.toggleFavorite(e.value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  final VoidCallback onTap;
  const SearchBox({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 30),
            SizedBox(width: 16),
            Text('Search contacts...', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

class QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const QuickCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 31,
                backgroundColor: scheme.primaryContainer,
                child: Icon(icon, size: 30, color: scheme.onPrimaryContainer),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Text(value, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 27,
          child: Text(
            contact.name.isEmpty ? '?' : contact.name[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(contact.phone),
        trailing: IconButton(
          onPressed: onFavorite,
          icon: Icon(
            contact.favorite ? Icons.star : Icons.star_border,
            color: contact.favorite ? Colors.amber : null,
          ),
        ),
      ),
    );
  }
}

class ContactsPage extends StatefulWidget {
  final String? group;
  const ContactsPage({super.key, this.group});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = store.contacts.where((c) {
      final matchesGroup = widget.group == null || c.group == widget.group;
      final q = query.toLowerCase();
      return matchesGroup &&
          (c.name.toLowerCase().contains(q) ||
              c.phone.toLowerCase().contains(q) ||
              c.email.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group ?? 'All Contacts'),
      ),
      bottomNavigationBar: const AppBottomBar(current: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddContact(context),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('No contacts found')),
            ),
          ...filtered.map(
            (c) => ContactTile(
              contact: c,
              onTap: () => openDetails(context, c),
              onFavorite: () => store.toggleFavorite(c),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = store.contacts.where((c) => c.favorite).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      bottomNavigationBar: const AppBottomBar(current: 2),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (favorites.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('No favorite contacts')),
            ),
          ...favorites.map(
            (c) => ContactTile(
              contact: c,
              onTap: () => openDetails(context, c),
              onFavorite: () => store.toggleFavorite(c),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            onPressed: () => showAddGroup(context),
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomBar(current: 3),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddGroup(context),
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: store.groups.length,
        itemBuilder: (context, index) {
          final group = store.groups[index];
          final count = store.contacts.where((c) => c.group == group).length;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const CircleAvatar(
                radius: 27,
                child: Icon(Icons.folder_outlined),
              ),
              title: Text(group, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('$count contacts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContactsPage(group: group),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ContactDetailsPage extends StatelessWidget {
  final Contact contact;
  const ContactDetailsPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final index = store.contacts.indexOf(contact);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        actions: [
          IconButton(
            onPressed: () => editContact(context, index),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () => deleteWithConfirm(context, index),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(
                contact.name.isEmpty ? '?' : contact.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              contact.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ),
          if (contact.group.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Chip(label: Text(contact.group)),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionCircle(icon: Icons.phone, label: 'Call', onTap: () => actionMessage(context, 'Call')),
              ActionCircle(icon: Icons.message_outlined, label: 'Message', onTap: () => actionMessage(context, 'Message')),
              ActionCircle(icon: Icons.chat_outlined, label: 'WhatsApp', onTap: () => actionMessage(context, 'WhatsApp')),
              ActionCircle(
                icon: contact.favorite ? Icons.star : Icons.star_border,
                label: 'Favorite',
                onTap: () => store.toggleFavorite(contact),
              ),
            ],
          ),
          const SizedBox(height: 28),
          InfoCard(
            title: 'Mobile',
            value: contact.phone,
            icon: Icons.phone_outlined,
          ),
          if (contact.secondPhone.isNotEmpty)
            InfoCard(
              title: 'Second Number',
              value: contact.secondPhone,
              icon: Icons.phone_android_outlined,
            ),
          if (contact.email.isNotEmpty)
            InfoCard(
              title: 'Email',
              value: contact.email,
              icon: Icons.email_outlined,
            ),
          if (contact.address.isNotEmpty)
            InfoCard(
              title: 'Address',
              value: contact.address,
              icon: Icons.location_on_outlined,
            ),
          if (contact.birthday.isNotEmpty)
            InfoCard(
              title: 'Birthday',
              value: contact.birthday,
              icon: Icons.cake_outlined,
            ),
          if (contact.notes.isNotEmpty)
            InfoCard(
              title: 'Notes',
              value: contact.notes,
              icon: Icons.notes_outlined,
            ),
        ],
      ),
    );
  }
}

class ActionCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionCircle({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 27,
          child: IconButton(onPressed: onTap, icon: Icon(icon)),
        ),
        const SizedBox(height: 7),
        Text(label),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(value),
        ),
      ),
    );
  }
}

class ContactFormPage extends StatefulWidget {
  final Contact? contact;
  final int? index;

  const ContactFormPage({super.key, this.contact, this.index});

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  late final TextEditingController name;
  late final TextEditingController phone;
  late final TextEditingController secondPhone;
  late final TextEditingController email;
  late final TextEditingController address;
  late final TextEditingController birthday;
  late final TextEditingController notes;
  String group = '';

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    name = TextEditingController(text: c?.name ?? '');
    phone = TextEditingController(text: c?.phone ?? '');
    secondPhone = TextEditingController(text: c?.secondPhone ?? '');
    email = TextEditingController(text: c?.email ?? '');
    address = TextEditingController(text: c?.address ?? '');
    birthday = TextEditingController(text: c?.birthday ?? '');
    notes = TextEditingController(text: c?.notes ?? '');
    group = c?.group ?? '';
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    secondPhone.dispose();
    email.dispose();
    address.dispose();
    birthday.dispose();
    notes.dispose();
    super.dispose();
  }

  void save() {
    if (name.text.trim().isEmpty || phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name और Mobile Number जरूरी हैं')),
      );
      return;
    }

    final old = widget.contact;
    final c = Contact(
      name: name.text.trim(),
      phone: phone.text.trim(),
      secondPhone: secondPhone.text.trim(),
      email: email.text.trim(),
      address: address.text.trim(),
      birthday: birthday.text.trim(),
      notes: notes.text.trim(),
      favorite: old?.favorite ?? false,
      group: group,
    );

    if (widget.index == null) {
      store.addContact(c);
    } else {
      store.updateContact(widget.index!, c);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.index != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit Contact' : 'Add Contact'),
        actions: [
          TextButton(
            onPressed: save,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              child: Text(
                name.text.isEmpty ? '?' : name.text[0].toUpperCase(),
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppField(controller: name, label: 'Full Name', icon: Icons.person_outline),
          AppField(controller: phone, label: 'Mobile Number', icon: Icons.phone_outlined, keyboard: TextInputType.phone),
          AppField(controller: secondPhone, label: 'Second Number', icon: Icons.phone_android_outlined, keyboard: TextInputType.phone),
          AppField(controller: email, label: 'Email', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
          AppField(controller: address, label: 'Address', icon: Icons.location_on_outlined, maxLines: 2),
          AppField(controller: birthday, label: 'Birthday', icon: Icons.cake_outlined),
          DropdownButtonFormField<String>(
            value: group.isEmpty ? null : group,
            decoration: InputDecoration(
              labelText: 'Group',
              prefixIcon: const Icon(Icons.folder_outlined),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('No Group')),
              ...store.groups.map((g) => DropdownMenuItem(value: g, child: Text(g))),
            ],
            onChanged: (v) => setState(() => group = v ?? ''),
          ),
          const SizedBox(height: 14),
          AppField(controller: notes, label: 'Notes', icon: Icons.notes_outlined, maxLines: 4),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: save,
            icon: const Icon(Icons.save_outlined),
            label: Text(editing ? 'Update Contact' : 'Save Contact'),
          ),
        ],
      ),
    );
  }
}

class AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboard;
  final int maxLines;

  const AppField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboard,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final results = store.contacts.where((c) {
      final q = query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search Contacts')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            autofocus: true,
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              hintText: 'Type name, number or email...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...results.map(
            (c) => ContactTile(
              contact: c,
              onTap: () => openDetails(context, c),
              onFavorite: () => store.toggleFavorite(c),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const SettingsPage({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SettingsSection(title: 'Appearance'),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: darkMode,
              onChanged: onDarkModeChanged,
            ),
          ),
          const SettingsSection(title: 'Contacts'),
          SettingsTile(
            icon: Icons.backup_outlined,
            title: 'Backup Contacts',
            subtitle: 'Create a backup file',
            onTap: () => actionMessage(context, 'Backup'),
          ),
          SettingsTile(
            icon: Icons.restore_outlined,
            title: 'Restore Contacts',
            subtitle: 'Restore contacts from backup',
            onTap: () => actionMessage(context, 'Restore'),
          ),
          SettingsTile(
            icon: Icons.delete_outline,
            title: 'Trash',
            subtitle: 'Deleted contacts',
            onTap: () => actionMessage(context, 'Trash'),
          ),
          const SettingsSection(title: 'Security'),
          SettingsTile(
            icon: Icons.lock_outline,
            title: 'App Lock',
            subtitle: 'Protect your Address Book',
            onTap: () => actionMessage(context, 'App Lock'),
          ),
          const SettingsSection(title: 'About'),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'About Address Book',
            subtitle: 'Version 1.0.0',
            onTap: () => showAbout(context),
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  const SettingsSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class AppBottomBar extends StatelessWidget {
  final int current;
  const AppBottomBar({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.contacts_outlined), selectedIcon: Icon(Icons.contacts), label: 'Contacts'),
        NavigationDestination(icon: Icon(Icons.star_border), selectedIcon: Icon(Icons.star), label: 'Favorites'),
        NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Groups'),
      ],
      onDestinationSelected: (index) {
        if (index == current) return;
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => const HomePageShell(),
          ));
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => const ContactsPage(),
          ));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => const FavoritesPage(),
          ));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => const GroupsPage(),
          ));
        }
      },
    );
  }
}

class HomePageShell extends StatelessWidget {
  const HomePageShell({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage(
      darkMode: Theme.of(context).brightness == Brightness.dark,
      onDarkModeChanged: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dark Mode setting खोलने के लिए Settings इस्तेमाल करें')),
        );
      },
    );
  }
}

void openContacts(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ContactsPage()),
  );
}

void openSearch(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SearchPage()),
  );
}

void openAddContact(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ContactFormPage()),
  );
}

void openDetails(BuildContext context, Contact contact) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ContactDetailsPage(contact: contact),
    ),
  );
}

void editContact(BuildContext context, int index) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ContactFormPage(
        contact: store.contacts[index],
        index: index,
      ),
    ),
  );
}

void deleteWithConfirm(BuildContext context, int index) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete Contact?'),
      content: const Text('क्या आप इस contact को delete करना चाहते हैं?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            store.deleteContact(index);
            Navigator.pop(dialogContext);
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

void showAddGroup(BuildContext context) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Create Group'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Group Name',
          prefixIcon: Icon(Icons.folder_outlined),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            store.addGroup(controller.text);
            Navigator.pop(dialogContext);
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

void actionMessage(BuildContext context, String action) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$action feature अगले चरण में phone integration के साथ जोड़ा जाएगा')),
  );
}

void showAbout(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: 'Address Book',
    applicationVersion: '1.0.0',
    applicationIcon: const Icon(Icons.contacts),
    children: const [
      Text('Simple and powerful contact management app.'),
    ],
  );
}
