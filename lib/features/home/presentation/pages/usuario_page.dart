import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  File? _photoFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _nameCtrl.text = prefs.getString('user_name') ?? '';
    _emailCtrl.text = prefs.getString('user_email') ?? '';
    _phoneCtrl.text = prefs.getString('user_phone') ?? '';
    final photoPath = prefs.getString('user_photo_path');
    if (photoPath != null && photoPath.isNotEmpty && File(photoPath).existsSync()) {
      setState(() => _photoFile = File(photoPath));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
      if (picked == null) return;
      final saved = await _saveImagePermanently(File(picked.path));
      setState(() => _photoFile = saved);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo seleccionar la imagen: $e')),
      );
    }
  }

  Future<File> _saveImagePermanently(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final destPath = '${dir.path}/profile.jpg';
    final saved = await file.copy(destPath);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_photo_path', saved.path);
    return saved;
  }

  String? _validateName(String? v) {
    final value = (v ?? '').trim();
    if (value.length < 2) return 'Escribe tu nombre (mín. 2 caracteres)';
    return null;
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return null;
    final emailReg = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailReg.hasMatch(value)) return 'Correo no válido';
    return null;
  }

  String? _validatePhone(String? v) {
    final value = (v ?? '').replaceAll(' ', '');
    if (value.isEmpty) return null;
    final digits = RegExp(r'^\+?\d{9,15}$');
    if (!digits.hasMatch(value)) return 'Teléfono no válido (9–15 dígitos)';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los campos')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameCtrl.text.trim());
      await prefs.setString('user_email', _emailCtrl.text.trim());
      await prefs.setString('user_phone', _phoneCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos guardados')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showPhotoSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Color(0xFFFF9800)),
                  title: const Text('Cámara'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFFFF9800)),
                  title: const Text('Galería'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuario'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _CardContainer(
                  child: GestureDetector(
                    onTap: _showPhotoSheet,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: const Color(0xFFF4F4F4),
                            backgroundImage: _photoFile != null ? FileImage(_photoFile!) : null,
                            child: _photoFile == null
                                ? const Icon(Icons.camera_alt, size: 36, color: Color(0xFFFF9800))
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _photoFile == null ? 'Añadir foto' : 'Cambiar foto',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Toca para seleccionar de cámara o galería',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Campos responsivos sin overflow
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 12.0;
                    final twoCols = constraints.maxWidth >= 360;
                    final itemWidth = twoCols ? ((constraints.maxWidth - gap) / 2) : constraints.maxWidth;

                    return Wrap(
                      spacing: gap,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _CardContainer(
                            child: _LabeledField(
                              icon: Icons.person,
                              label: 'Nombre*',
                              controller: _nameCtrl,
                              validator: _validateName,
                              keyboardType: TextInputType.name,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _CardContainer(
                            child: _LabeledField(
                              icon: Icons.email_outlined,
                              label: 'Correo (opcional)',
                              controller: _emailCtrl,
                              validator: _validateEmail,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth,
                          child: _CardContainer(
                            child: _LabeledField(
                              icon: Icons.phone_outlined,
                              label: 'Teléfono (opcional)',
                              controller: _phoneCtrl,
                              validator: _validatePhone,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Botón Guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _saving
                        ? const SizedBox(
                        height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LabeledField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _LabeledField({
    required this.icon,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 2),
            Icon(icon, color: const Color(0xFFFF9800), size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
