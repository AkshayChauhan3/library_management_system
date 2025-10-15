import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<DocumentSnapshot> userStream = const Stream.empty();
  Stream<QuerySnapshot>? bookStream;
  String? cachedQrData;
  bool showQr = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  String _getRemainingDays(Timestamp dueDate) {
    final now = DateTime.now();
    final due = dueDate.toDate();
    final difference = due.difference(now);
    final days = difference.inDays;

    if (days < 0) {
      return 'Overdue by ${days.abs()} days';
    } else if (days == 0) {
      return 'Due today';
    } else {
      return '$days days remaining';
    }
  }

  Future<void> _initializeUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid =
          FirebaseAuth.instance.currentUser?.uid ?? prefs.getString('uid');

      if (uid == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      prefs.setString('uid', uid);

      setState(() {
        userStream = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots();
        
        // Initialize book stream immediately
        bookStream = FirebaseFirestore.instance
            .collection('bookTransactions')
            .where('userId', isEqualTo: uid)
            .where('status', isEqualTo: 'borrowed')
            .snapshots();
      });
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '-';
    final date = ts.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  String _generateQrData(Map<String, dynamic>? userData) {
    final current = FirebaseAuth.instance.currentUser;
    final name =
        (userData != null &&
            userData['fullName'] != null &&
            userData['fullName'].toString().isNotEmpty)
        ? userData['fullName'].toString()
        : (current?.displayName ?? '-');
    final enrollment = (userData != null && userData['enrollment'] != null)
        ? userData['enrollment'].toString()
        : '-';
    final department = (userData != null && userData['department'] != null)
        ? userData['department'].toString()
        : '-';
    final semester = (userData != null && userData['semester'] != null)
        ? userData['semester'].toString()
        : '-';
    final email =
        (userData != null &&
            userData['email'] != null &&
            userData['email'].toString().isNotEmpty)
        ? userData['email'].toString()
        : (current?.email ?? '-');

    return '''
Name: $name
Enrollment: $enrollment
Department: $department
Semester: $semester
Email: $email
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Welcome, Student',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userStream,
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return const Center(child: Text('Error loading user data'));
          }

          if (userSnapshot.connectionState == ConnectionState.waiting ||
              userSnapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
          final bool isCheckedIn = userData?['checkedIn'] ?? false;

          cachedQrData ??= userData != null ? _generateQrData(userData) : '';
          final bool checkedIn =
              (userData != null && userData['checkedIn'] == true);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Check-in status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCheckedIn ? Colors.green[900] : Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCheckedIn ? Colors.green : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCheckedIn ? 'Currently Checked In' : 'Not Checked In',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isCheckedIn && userData?['lastCheckIn'] != null)
                        Text(
                          'Since: ${_formatDate(userData?['lastCheckIn'])}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Library ID Card with QR
                InkWell(
                  onTap: () {
                    setState(() {
                      showQr = !showQr;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white24.withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Library ID Card",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              showQr ? Icons.expand_less : Icons.expand_more,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              checkedIn
                                  ? 'Status: Checked in'
                                  : 'Status: Not checked in',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        if (showQr) ...[
                          const SizedBox(height: 12),
                          QrImageView(
                            data: cachedQrData ?? '',
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Present QR at library counter",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Issued Books Section
                StreamBuilder<QuerySnapshot>(
                  stream: bookStream,
                  builder: (context, bookSnapshot) {
                    if (bookSnapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (bookSnapshot.hasError) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            "Error: ${bookSnapshot.error}",
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      );
                    }

                    if (!bookSnapshot.hasData || 
                        bookSnapshot.data == null ||
                        bookSnapshot.data!.docs.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Center(
                          child: Text(
                            "No books issued currently.",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      );
                    }

                    // Get all borrowed books
                    final borrowedBooks = bookSnapshot.data!.docs;

                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            borrowedBooks.length == 1
                                ? "Issued Book Details"
                                : "Issued Books (${borrowedBooks.length})",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...borrowedBooks.map((doc) {
                            final bookData = doc.data() as Map<String, dynamic>;
                            return Column(
                              children: [
                                _buildBookCard(bookData),
                                if (doc != borrowedBooks.last)
                                  const Divider(
                                    color: Colors.white24,
                                    height: 32,
                                    thickness: 1,
                                  ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/books');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> bookData) {
    final dueDate = bookData['dueDate'] as Timestamp?;
    final isOverdue = dueDate != null && dueDate.toDate().isBefore(DateTime.now());
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bookRow("Book Name", bookData['title'] ?? bookData['bookName'] ?? '-'),
        _bookRow("Author", bookData['author'] ?? '-'),
        _bookRow("Issued Date", _formatDate(bookData['issueDate'])),
        _bookRow("Due Date", _formatDate(dueDate)),
        if (dueDate != null)
          _bookRow(
            "Status",
            _getRemainingDays(dueDate),
            valueColor: isOverdue ? Colors.red : Colors.green,
          ),
      ],
    );
  }

  Widget _bookRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}