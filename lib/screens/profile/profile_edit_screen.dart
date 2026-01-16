import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/supabase_service.dart';
import '../../data/models/user_profile.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserProfile? profile;
  const ProfileEditScreen({super.key, this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  // Location Data
  List<dynamic> _provinces = [];
  List<dynamic> _regencies = [];
  List<dynamic> _districts = [];

  String? _selectedProvId;
  String? _selectedRegencyId;

  // Form Values
  String? _selectedProvName;
  String? _selectedRegencyName;
  String? _selectedDistrictName;
  String? _selectedTanaman;

  final List<String> _tanamanData = [
    "Padi",
    "Jagung",
    "Cabai",
    "Bawang Merah",
    "Sayuran",
    "Buah-buahan",
    "Palawija"
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  String _normalizeName(String name) {
    return name
        .toUpperCase()
        .replaceAll('KABUPATEN', '')
        .replaceAll('KOTA', '')
        .replaceAll('DI ', '')
        .replaceAll('DKI ', '')
        .trim();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _fetchProvinces(); // Ensure this handles cache
    final profile = widget.profile ?? await SupabaseService().getUserProfile();

    if (profile != null) {
      _nameController.text = profile.nama ?? "";
      _phoneController.text = profile.noHp ?? "";
      _usernameController.text = profile.username ?? "";
      _selectedTanaman = profile.jenisTanaman;

      // Set initial names from profile
      _selectedProvName = profile.provinsi;
      _selectedRegencyName = profile.kota;
      _selectedDistrictName = profile.kecamatan;

      // Robust ID Restoration Logic
      if (_selectedProvName != null) {
        final normProfileProv = _normalizeName(_selectedProvName!);

        final prov = _provinces.firstWhere(
            (p) => _normalizeName(p['name'].toString()) == normProfileProv,
            orElse: () => null);

        if (prov != null) {
          _selectedProvId = prov['id'];
          // Use the API name to ensure consistency
          _selectedProvName = prov['name'];

          await _fetchRegencies(_selectedProvId!, reset: false);

          if (_selectedRegencyName != null) {
            final normProfileReg = _normalizeName(_selectedRegencyName!);

            final reg = _regencies.firstWhere(
                (r) => _normalizeName(r['name'].toString()) == normProfileReg,
                orElse: () => null);

            if (reg != null) {
              _selectedRegencyId = reg['id'];
              _selectedRegencyName = reg['name'];

              await _fetchDistricts(_selectedRegencyId!, reset: false);

              if (_selectedDistrictName != null) {
                final normProfileDist = _normalizeName(_selectedDistrictName!);
                final dist = _districts.firstWhere(
                    (d) =>
                        _normalizeName(d['name'].toString()) == normProfileDist,
                    orElse: () => null);
                if (dist != null) {
                  _selectedDistrictName = dist['name'];
                }
              }
            }
          }
        }
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // --- API Fetching ---
  Future<void> _fetchProvinces() async {
    const cacheKey = 'cached_provinces';
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _provinces = data);

        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, res.body);
      }
    } catch (e) {
      debugPrint("Error fetching provinces: $e");
      // Load from cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(cacheKey);
        if (cached != null) {
          setState(() => _provinces = jsonDecode(cached));
        }
      } catch (_) {}
    }
  }

  Future<void> _fetchRegencies(String provId, {bool reset = true}) async {
    try {
      if (reset) {
        setState(() {
          _regencies = [];
          _districts = [];
          _selectedRegencyId = null;
          _selectedRegencyName = null;
          _selectedDistrictName = null;
        });
      }
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provId.json'));
      if (res.statusCode == 200) {
        setState(() => _regencies = jsonDecode(res.body));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchDistricts(String regencyId, {bool reset = true}) async {
    try {
      if (reset) {
        setState(() {
          _districts = [];
          _selectedDistrictName = null;
        });
      }
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/districts/$regencyId.json'));
      if (res.statusCode == 200) {
        setState(() => _districts = jsonDecode(res.body));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      // Validate Dropdowns manually
      if (_selectedProvName == null ||
          _selectedRegencyName == null ||
          _selectedDistrictName == null ||
          _selectedTanaman == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("Mohon lengkapi data Provinsi, Kota, Kecamatan & Tanaman"),
            backgroundColor: Colors.red));
        return;
      }

      setState(() => _isSaving = true);
      try {
        await SupabaseService().updateUserProfile(
          nama: _nameController.text,
          noHp: _phoneController.text,
          kota: _selectedRegencyName ?? "",
          provinsi: _selectedProvName,
          kecamatan: _selectedDistrictName,
          jenisTanaman: _selectedTanaman,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profil Berhasil Disimpan!")));
          context.pop();
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Gagal: $e")));
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(children: [
                _buildHeader(),
                // Floating Card Effect
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]),
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Form Fields ---
                            _buildLabel("Nama Lengkap"),
                            TextFormField(
                              controller: _nameController,
                              decoration: _inputDecoration("Nama lengkap anda"),
                              validator: (v) =>
                                  v!.isEmpty ? "Nama wajib diisi" : null,
                            ),
                            const SizedBox(height: 16),

                            _buildLabel("No. Telepon"),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration("xx-xxx-xxx"),
                              validator: (v) =>
                                  v!.isEmpty ? "Telepon wajib diisi" : null,
                            ),
                            const SizedBox(height: 16),

                            _buildLabel("Username (Tidak dapat diubah)"),
                            TextFormField(
                              controller: _usernameController,
                              readOnly: true,
                              style: const TextStyle(color: Colors.grey),
                              decoration: _inputDecoration("username").copyWith(
                                fillColor: Colors.grey[100],
                                filled: true,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Province Selector
                            _buildLabel("Provinsi"),
                            _buildSearchableDropdown(
                              label: _selectedProvName ?? "Pilih Provinsi",
                              hint: "Cari Provinsi...",
                              items: _provinces,
                              onSelect: (item) {
                                setState(() {
                                  _selectedProvId = item['id'];
                                  _selectedProvName = item['name'];
                                  // Reset sub-levels
                                  _selectedRegencyId = null;
                                  _selectedRegencyName = null;
                                  _regencies = [];
                                  _selectedDistrictName = null;
                                  _districts = [];
                                });
                                _fetchRegencies(item['id']);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Regency Selector
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
                                  // Reset sub-level
                                  _selectedDistrictName = null;
                                  _districts = [];
                                });
                                _fetchDistricts(item['id']);
                              },
                            ),
                            const SizedBox(height: 16),

                            // District Selector
                            _buildLabel("Kecamatan"),
                            _buildSearchableDropdown(
                              label: _selectedDistrictName ?? "Pilih Kecamatan",
                              hint: "Cari Kecamatan...",
                              items: _districts,
                              enabled: _selectedRegencyId != null,
                              onSelect: (item) {
                                setState(() {
                                  _selectedDistrictName =
                                      item['name']; // Use Name as value
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildLabel("Jenis Tanaman Utama"),
                            DropdownButtonFormField<String>(
                              value: _selectedTanaman,
                              decoration: _inputDecoration("Palawija"),
                              items: _tanamanData
                                  .map((t) => DropdownMenuItem(
                                      value: t, child: Text(t)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedTanaman = v),
                              validator: (v) =>
                                  v == null ? "Pilih Tanaman" : null,
                            ),

                            const SizedBox(height: 32),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => context.pop(),
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text("Batal"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: _isSaving ? null : _handleSave,
                                    icon: _isSaving
                                        ? const SizedBox.shrink()
                                        : const Icon(Icons.check, size: 18),
                                    label: _isSaving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2))
                                        : const Text("Simpan"),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF166534),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
    );
  }

// --- Custom Searchable Dropdown Logic ---
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? Colors.transparent : Colors.grey[100],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: label.startsWith("Pilih")
                      ? Colors.grey[600]
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 240, // Tall header like image
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: Color(0xFF166534),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 3),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 12),
          const Text("Edit Profil",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700])),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              color: Colors.grey)), // Darker grey for visibility
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF166534), width: 2)),
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
