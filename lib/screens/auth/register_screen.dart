import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/services/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController(); // NEW
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otherCropController = TextEditingController(); // NEW

  // Location Data (Cascading)
  List<dynamic> _provinces = [];
  List<dynamic> _regencies = [];
  List<dynamic> _districts = [];

  String? _selectedProvId;
  String? _selectedRegencyId;

  String? _selectedProvName;
  String? _selectedRegencyName;
  String? _selectedDistrictName;

  String? _selectedCrop;
  final List<String> _cropTypes = [
    'Padi',
    'Jagung',
    'Cabai',
    'Bawang Merah',
    'Kedelai',
    'Kentang',
    'Tomat',
    'Lainnya'
  ];

  final _authService = SupabaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  // --- API Fetching ---
  Future<void> _fetchProvinces() async {
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json'));
      if (res.statusCode == 200) {
        setState(() => _provinces = jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("Error fetching provinces: $e");
    }
  }

  Future<void> _fetchRegencies(String provId) async {
    try {
      // Reset lower levels
      setState(() {
        _regencies = [];
        _districts = [];
        _selectedRegencyId = null;
        _selectedRegencyName = null;
        _selectedDistrictName = null;
      });

      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provId.json'));
      if (res.statusCode == 200) {
        setState(() => _regencies = jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("Error fetching regencies: $e");
    }
  }

  Future<void> _fetchDistricts(String regencyId) async {
    try {
      // Reset lower level
      setState(() {
        _districts = [];
        _selectedDistrictName = null;
      });

      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/districts/$regencyId.json'));
      if (res.statusCode == 200) {
        setState(() => _districts = jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("Error fetching districts: $e");
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Custom Validation for Location
    if (_selectedProvName == null ||
        _selectedRegencyName == null ||
        _selectedDistrictName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lengkapi data lokasi (Provinsi, Kota, Kecamatan)'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedCrop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih jenis tanaman utama Anda'),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Determine final crop name
    String finalCrop = _selectedCrop!;
    if (_selectedCrop == 'Lainnya') {
      if (_otherCropController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sebutkan jenis tanaman Anda'),
              backgroundColor: Colors.red),
        );
        return;
      }
      finalCrop = _otherCropController.text.trim();
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        nama: _nameController.text.trim(),
        noHp: _phoneController.text.trim(),
        provinsi: _selectedProvName!,
        kota: _selectedRegencyName!,
        kecamatan: _selectedDistrictName!,
        jenisTanaman: finalCrop,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil! Silakan login."),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Terjadi kesalahan: $e"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Data Diri",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person,
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.alternate_email,
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                inputType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Email tidak valid' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (v) =>
                    (v?.length ?? 0) < 6 ? 'Min. 6 karakter' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: 'No. WhatsApp / HP',
                icon: Icons.phone,
                inputType: TextInputType.phone,
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              const Text("Lokasi & Lahan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),

              // --- Cascading Location Dropdowns ---
              _buildLabel("Provinsi"),
              _buildSearchableDropdown(
                label: _selectedProvName ?? "Pilih Provinsi",
                hint: "Cari Provinsi...",
                items: _provinces,
                onSelect: (item) {
                  setState(() {
                    _selectedProvId = item['id'];
                    _selectedProvName = item['name'];
                  });
                  _fetchRegencies(item['id']);
                },
              ),
              const SizedBox(height: 12),

              _buildLabel("Kabupaten/Kota"),
              _buildSearchableDropdown(
                label: _selectedRegencyName ?? "Pilih Kabupaten",
                hint: "Cari Kabupaten...",
                items: _regencies,
                enabled: _selectedProvId != null,
                onSelect: (item) {
                  setState(() {
                    _selectedRegencyId = item['id'];
                    _selectedRegencyName = item['name'];
                  });
                  _fetchDistricts(item['id']);
                },
              ),
              const SizedBox(height: 12),

              _buildLabel("Kecamatan"),
              _buildSearchableDropdown(
                label: _selectedDistrictName ?? "Pilih Kecamatan",
                hint: "Cari Kecamatan...",
                items: _districts,
                enabled: _selectedRegencyId != null,
                onSelect: (item) {
                  setState(() {
                    _selectedDistrictName = item['name'];
                  });
                },
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCrop,
                decoration: const InputDecoration(
                  labelText: 'Jenis Tanaman Utama',
                  prefixIcon: Icon(Icons.grass),
                  border: OutlineInputBorder(),
                ),
                items: _cropTypes
                    .map((crop) =>
                        DropdownMenuItem(value: crop, child: Text(crop)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCrop = val),
                validator: (v) => v == null ? 'Pilih jenis tanaman' : null,
              ),
              if (_selectedCrop == 'Lainnya') ...[
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _otherCropController,
                  label: 'Sebutkan Tanaman Lainnya',
                  icon: Icons.edit_note,
                  validator: (v) =>
                      _selectedCrop == 'Lainnya' && (v?.isEmpty ?? true)
                          ? 'Wajib diisi'
                          : null,
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Daftar Sekarang",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text("Sudah punya akun? Masuk"),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      keyboardType: inputType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  // Copied & Adapted Searchable Dropdown Helper
  Widget _buildSearchableDropdown({
    required String label,
    required String hint,
    required List<dynamic> items,
    required Function(dynamic) onSelect,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? () => _showSearchModal(hint, items, onSelect) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
          color: enabled ? Colors.transparent : Colors.grey[200],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: label.startsWith("Pilih")
                      ? Colors.grey[700]
                      : Colors.black,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showSearchModal(
      String hint, List<dynamic> items, Function(dynamic) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) =>
          _SearchModal(hint: hint, items: items, onSelect: onSelect),
    );
  }
}

// Search Modal Widget
class _SearchModal extends StatefulWidget {
  final String hint;
  final List<dynamic> items;
  final Function(dynamic) onSelect;

  const _SearchModal(
      {required this.hint, required this.items, required this.onSelect});

  @override
  State<_SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<_SearchModal> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((item) => item['name']
            .toString()
            .toLowerCase()
            .contains(_query.toLowerCase()))
        .toList();

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: widget.hint,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("Tidak ditemukan"))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ListTile(
                          title: Text(item['name']),
                          onTap: () {
                            widget.onSelect(item);
                            context.pop();
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
