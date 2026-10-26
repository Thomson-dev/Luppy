import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luppy/auth/model/sign_up_models.dart';
import 'package:luppy/auth/widget/Label.dart';
import 'package:luppy/auth/widget/chipSelect.dart';
import 'package:luppy/profile/Model/Profile.dart';
import 'package:luppy/profile/provider/profile_provider.dart';
import 'package:luppy/profile/widgets/Form.dart';
import 'package:luppy/profile/widgets/PhotoGrid.dart';

import '../widgets/PreviewCard.dart';

import '../widgets/ModeTabs.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final DogProfile profile;
  final ValueChanged<DogProfile>? onSave;

  const EditProfileScreen({super.key, required this.profile, this.onSave});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  static const Color _pink = Color(0xFFFF4081);
  static const Color _pinkLight = Color(0xFFFF8FC4);
  late final TabController _tabs;
  late DogProfile profile;
  final _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void update(DogProfile next) => setState(() => profile = next);

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(profileNotifierProvider.notifier).saveProfile(profile);
      widget.onSave?.call(profile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Color(0xFF22DD3A),
          ),
        );
        Navigator.maybePop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> addPhoto() async {
    if (!profile.canAddPhoto) return;

    // Show bottom sheet to choose gallery or camera
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF16161A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Choose from gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Take a photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );

    if (!mounted || picked == null) return;
    debugPrint('[EditProfile] Photo picked: ${picked.path}');
    update(profile.copyWith(photos: [...profile.photos, picked.path]));
  }

  void removePhoto(int index) {
    debugPrint('[EditProfile] Removing photo at index $index');
    final next = [...profile.photos]..removeAt(index);
    update(profile.copyWith(photos: next));
  }

  Future<void> pickBirthDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: profile.birthDate ?? now,
      firstDate: DateTime(now.year - 30),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _pink,
            surface: Color(0xFF16161A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) update(profile.copyWith(birthDate: picked));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: Text(_tabs.index == 1 ? 'Preview Profile' : 'Edit Profile'),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/Notification 4.png',
              width: 28,
              height: 28,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset('assets/Menu.png', width: 28, height: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: ModeTabs(controller: _tabs),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [_buildForm(), _buildPreview()],
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit tab ────────────────────────────────────────────────────────────

  Widget _buildForm() {
    final text = Theme.of(context).textTheme;
    final age = profile.ageAt(DateTime.now());
    const fieldBorder = Color(0xFF2A2A32);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile pictures:',
            style: text.titleMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            'Upload a new profile picture for your dog.',
            style: text.bodySmall?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 14),
          PhotoGrid(
            photos: profile.photos,
            onAdd: addPhoto,
            onRemove: removePhoto,
          ),
          const SizedBox(height: 32),
          Text(
            'Basic Information',
            style: text.titleMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            'Tell us more about your \u{1F436} friend',
            style: text.bodySmall?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 20),
          Labeled(
            "Dog's Name",
            Input(
              initialValue: profile.name,
              hint: "Enter your dog's name",
              onChanged: (v) => update(profile.copyWith(name: v)),
            ),
          ),
          Labeled(
            'About Your \u{1F436}',
            Input(
              initialValue: profile.about,
              hint: 'Tell us about your dog.',
              maxLines: 4,
              maxLength: 450,
              onChanged: (v) => update(profile.copyWith(about: v)),
            ),
          ),
          Labeled(
            "Dog's Age",
            GestureDetector(
              onTap: pickBirthDate,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131317),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: fieldBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        age?.label ?? 'Select Age',
                        style: TextStyle(
                          fontSize: 14,
                          color: age == null
                              ? const Color(0xFF7C7C86)
                              : Colors.white,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 20),
                  ],
                ),
              ),
            ),
          ),
          Labeled(
            'Breed',
            Input(
              initialValue: profile.breed,
              hint: "Enter your dog's breed",
              onChanged: (v) => update(profile.copyWith(breed: v)),
            ),
          ),
          OptionRow<DogGender>(
            label: 'Gender:',
            options: DogGender.values,
            selected: profile.gender,
            labelOf: (g) => g.label,
            onSelected: (g) => update(profile.copyWith(gender: g)),
          ),
          const SizedBox(height: 20),
          OptionRow<DogSize>(
            label: 'Size:',
            options: DogSize.values,
            selected: profile.size,
            labelOf: (s) => s.label,
            onSelected: (s) => update(profile.copyWith(size: s)),
          ),
          const SizedBox(height: 32),
          Text('Interests and Preferences', style: text.titleMedium),
          const SizedBox(height: 6),
          Text(
            'What does your dog love?',
            style: text.bodySmall?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 20),
          Text('Temperament:', style: text.bodyLarge?.copyWith(fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              for (final t in Temperament.values)
                SelectChip(
                  label: t.label,
                  selected: profile.temperaments.contains(t),
                  onTap: () {
                    final next = {...profile.temperaments};
                    next.contains(t) ? next.remove(t) : next.add(t);
                    update(profile.copyWith(temperaments: next));
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Interests:', style: text.bodyLarge?.copyWith(fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              for (final i in DogInterest.values)
                SelectChip(
                  label: i.label,
                  selected: profile.interests.contains(i),
                  onTap: () {
                    final next = {...profile.interests};
                    next.contains(i) ? next.remove(i) : next.add(i);
                    update(profile.copyWith(interests: next));
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Energy Level:', style: text.bodyLarge?.copyWith(fontSize: 14)),
          Slider(
            value: profile.energyLevel,
            activeColor: _pink,
            inactiveColor: const Color(0xFF6B6776),
            onChanged: (v) => update(profile.copyWith(energyLevel: v)),
          ),
          Row(
            children: [
              Text('Trained:', style: text.bodyLarge?.copyWith(fontSize: 14)),
              const Spacer(),
              Switch(
                value: profile.isTrained,
                activeColor: _pink,
                onChanged: (v) => update(profile.copyWith(isTrained: v)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Labeled(
            'Social Media',
            Input(
              initialValue: profile.instagram,
              hint: '@yourdog (Instagram)',
              onChanged: (v) => update(profile.copyWith(instagram: v)),
            ),
          ),
          const SizedBox(height: 16),
          _GradientButton(
            label: _isSaving ? 'Saving...' : 'Save',
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _save,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Preview tab ─────────────────────────────────────────────────────────

  Widget _buildPreview() {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile preview:', style: text.titleMedium?.copyWith(fontSize: 20, fontWeight: FontWeight(700))),
          const SizedBox(height: 6),
          Text(
            "Click on the card and check your dog's info.",
            style: text.bodySmall?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 14),
          Expanded(child: PreviewCard(profile: profile)),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GradientButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _EditProfileScreenState._pinkLight,
            _EditProfileScreenState._pink,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
