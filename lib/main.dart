import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const SoulJournalApp());
}

class JournalEntry {
  final String id;
  String content;
  DateTime date;
  int colorIndex;

  JournalEntry({
    required this.id,
    required this.content,
    required this.date,
    required this.colorIndex,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'date': date.toIso8601String(),
        'colorIndex': colorIndex,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'],
        content: json['content'],
        date: DateTime.parse(json['date']),
        colorIndex: json['colorIndex'],
      );
}

class SoulJournalApp extends StatelessWidget {
  const SoulJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'soulJournal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFDFCF2), // Cream off-white
      ),
      home: const ScrapbookHome(),
    );
  }
}

class ScrapbookHome extends StatefulWidget {
  const ScrapbookHome({super.key});

  @override
  State<ScrapbookHome> createState() => _ScrapbookHomeState();
}

class _ScrapbookHomeState extends State<ScrapbookHome> {
  List<JournalEntry> entries = [];
  bool isLoading = true;
  String? _activeDeleteId;

  final List<Color> pastelColors = [
    const Color(0xFFD7F9E9), // Mint
    const Color(0xFFFDE2E4), // Pink
    const Color(0xFFE2E2FF), // Lavender
    const Color(0xFFFFF1E6), // Peach
    const Color(0xFFDFE7FD), // Ice Blue
    const Color(0xFFF0E6EF), // Soft Purple
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString('entries');
    if (entriesJson != null) {
      final List<dynamic> decodedList = jsonDecode(entriesJson);
      setState(() {
        entries = decodedList.map((e) => JournalEntry.fromJson(e)).toList();
        entries.sort((a, b) => a.date.compareTo(b.date));
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String entriesJson =
        jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString('entries', entriesJson);
  }

  void _addOrUpdateEntry(JournalEntry entry, bool isNew) {
    setState(() {
      if (isNew) {
        entries.add(entry);
      } else {
        final index = entries.indexWhere((e) => e.id == entry.id);
        if (index != -1) {
          entries[index] = entry;
        }
      }
      entries.sort((a, b) => a.date.compareTo(b.date));
    });
    _saveEntries();
  }

  void _deleteEntry(String id) {
    final index = entries.indexWhere((e) => e.id == id);
    if (index == -1) return;
    
    final deletedEntry = entries[index];
    
    setState(() {
      entries.removeAt(index);
      if (_activeDeleteId == id) _activeDeleteId = null;
    });
    _saveEntries();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Journal entry deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              entries.insert(index, deletedEntry);
            });
            _saveEntries();
          },
        ),
      ),
    );
  }

  void _showEntryPopup([JournalEntry? existingEntry]) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return EntryDialog(
          existingEntry: existingEntry,
          pastelColors: pastelColors,
          onSave: (content, colorIndex) {
            if (existingEntry == null) {
              final newEntry = JournalEntry(
                id: const Uuid().v4(),
                content: content,
                date: DateTime.now(),
                colorIndex: colorIndex,
              );
              _addOrUpdateEntry(newEntry, true);
            } else {
              existingEntry.content = content;
              existingEntry.colorIndex = colorIndex;
              existingEntry.date = DateTime.now();
              _addOrUpdateEntry(existingEntry, false);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background grainy texture
          const Positioned.fill(
            child: RepaintBoundary(
              child: GrainBackground(),
            ),
          ),
          // Main content
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 60.0, bottom: 40.0),
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF7C5C8E), // deep mauve
                                  Color(0xFFD4748C), // dusty rose
                                  Color(0xFFE8A87C), // warm amber
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(bounds),
                              child: Text(
                                'SoulJournal',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (entries.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'ningalde story evide start cheyunuu...',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20.0,
                              crossAxisSpacing: 20.0,
                              childAspectRatio: 0.85,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final entry = entries[index];
                                return ScrapbookCard(
                                  key: ValueKey(entry.id),
                                  color: pastelColors[entry.colorIndex],
                                  entry: entry,
                                  showDelete: _activeDeleteId == entry.id,
                                  onDelete: () => _deleteEntry(entry.id),
                                  onTap: () {
                                    if (_activeDeleteId != null) {
                                      setState(() => _activeDeleteId = null);
                                    }
                                  },
                                  onEdit: () {
                                    if (_activeDeleteId == null) {
                                      _showEntryPopup(entry);
                                    }
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      _activeDeleteId = _activeDeleteId == entry.id ? null : entry.id;
                                    });
                                  },
                                );
                              },
                              childCount: entries.length,
                            ),
                          ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 120),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntryPopup(),
        backgroundColor: Colors.white,
        elevation: 1,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.add,
          color: Color(0xFF2D2D2D),
          size: 30,
        ),
      ),
    );
  }
}

class ScrapbookCard extends StatelessWidget {
  final Color color;
  final JournalEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onLongPress;
  final bool showDelete;

  const ScrapbookCard({
    super.key,
    required this.color,
    required this.entry,
    required this.onDelete,
    required this.onTap,
    required this.onEdit,
    required this.onLongPress,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hour = entry.date.hour == 0 ? 12 : (entry.date.hour > 12 ? entry.date.hour - 12 : entry.date.hour);
    final amPm = entry.date.hour >= 12 ? 'PM' : 'AM';
    final minute = entry.date.minute.toString().padLeft(2, '0');
    final dateStr = '${entry.date.day}/${entry.date.month}/${entry.date.year}';
    final timeStr= '$hour:$minute $amPm';

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.vibrate();
        onLongPress();
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              if (!showDelete)
                Positioned(
                  top: 12,
                  left: 12,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.5),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(36, 36),
                    ),
                    icon: Icon(
                      Icons.edit_rounded,
                      color: Colors.black.withValues(alpha: 0.6),
                      size: 18,
                    ),
                    onPressed: onEdit,
                  ),
                ),

              if (!showDelete)
                Positioned(
                  top: 22,
                  right: 16,
                  child: Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.3),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

              if (!showDelete)
                Positioned(
                  top: 177,
                  right: 16,
                  child: Text(
                    timeStr,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.3),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

              if (showDelete)
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(36, 36),
                    ),
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: 18,
                    ),
                    onPressed: onDelete,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.content,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class EntryDialog extends StatefulWidget {
  final JournalEntry? existingEntry;
  final List<Color> pastelColors;
  final void Function(String content, int colorIndex) onSave;

  const EntryDialog({
    super.key,
    this.existingEntry,
    required this.pastelColors,
    required this.onSave,
  });

  @override
  State<EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  late TextEditingController _controller;
  late int _currentColorIndex;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.existingEntry?.content ?? '');
    _currentColorIndex = widget.existingEntry?.colorIndex ??
        Random().nextInt(widget.pastelColors.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (text.isEmpty) return;
    final newIndex = text.length % widget.pastelColors.length;
    if (newIndex != _currentColorIndex) {
      setState(() => _currentColorIndex = newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: widget.pastelColors[_currentColorIndex],
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    isEditing ? 'Edit Entry' : 'New Entry',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.5),
                      shape: const CircleBorder(),
                      minimumSize: const Size(32, 32),
                      padding: const EdgeInsets.all(4),
                    ),
                    icon: const Icon(Icons.close, size: 18, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Text field
              Container(
                constraints: const BoxConstraints(minHeight: 120, maxHeight: 260),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLines: null,
                  onChanged: _onTextChanged,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Save button
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    widget.onSave(
                      _controller.text.trim(),
                      _currentColorIndex,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Save',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GrainBackground extends StatelessWidget {
  const GrainBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GrainPainter(),
    );
  }
}

class GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint();

    for (var i = 0; i < 15000; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = random.nextDouble() * 0.04;

      paint.color = Colors.black.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(x, y),
        0.4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}