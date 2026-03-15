import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/services/database_service.dart';
import '../../data/models/plant.dart';
import '../widgets/plant_image.dart';

class PlantFormPage extends StatefulWidget {
  final Plant? plant;

  const PlantFormPage({super.key, this.plant});

  @override
  State<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends State<PlantFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _scientificNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _medicalUsesController;
  late TextEditingController _preparationMethodController;
  late TextEditingController _relatedDiseasesController;
  late TextEditingController _usedPartController;
  late TextEditingController _chemicalCompositionController;
  late TextEditingController _contraindicationsController;
  String _imageUrl = '';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant?.name ?? '');
    _scientificNameController = TextEditingController(text: widget.plant?.scientificName ?? '');
    _descriptionController = TextEditingController(text: widget.plant?.description ?? '');
    _medicalUsesController = TextEditingController(text: widget.plant?.medicalUses ?? '');
    _preparationMethodController = TextEditingController(text: widget.plant?.preparationMethod ?? '');
    _relatedDiseasesController = TextEditingController(text: widget.plant?.relatedDiseases ?? '');
    _usedPartController = TextEditingController(text: widget.plant?.usedPart ?? '');
    _chemicalCompositionController = TextEditingController(text: widget.plant?.chemicalComposition ?? '');
    _contraindicationsController = TextEditingController(text: widget.plant?.contraindications ?? '');
    _imageUrl = widget.plant?.imageUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scientificNameController.dispose();
    _descriptionController.dispose();
    _medicalUsesController.dispose();
    _preparationMethodController.dispose();
    _relatedDiseasesController.dispose();
    _usedPartController.dispose();
    _chemicalCompositionController.dispose();
    _contraindicationsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrl = pickedFile.path; // Temporary, will be saved on submit
      });
    }
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    String finalImageUrl = _imageUrl;

    // Save image to local storage if it's a new picked image
    if (_imageFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(_imageFile!.path);
      final savedImage = await _imageFile!.copy('${directory.path}/$fileName');
      finalImageUrl = savedImage.path;
    }

    final plant = Plant(
      id: widget.plant?.id,
      name: _nameController.text,
      scientificName: _scientificNameController.text,
      description: _descriptionController.text,
      medicalUses: _medicalUsesController.text,
      preparationMethod: _preparationMethodController.text,
      relatedDiseases: _relatedDiseasesController.text,
      usedPart: _usedPartController.text,
      chemicalComposition: _chemicalCompositionController.text,
      contraindications: _contraindicationsController.text,
      imageUrl: finalImageUrl,
    );

    if (widget.plant == null) {
      await DatabaseService.instance.insertPlant(plant);
    } else {
      await DatabaseService.instance.updatePlant(plant);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.plant != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text(isEditing ? 'Ösümligi redaktirlemek' : 'Täze ösümlik goşmak'),
        actions: [
          IconButton(
            onPressed: _savePlant,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'Ady', Icons.eco),
              _buildTextField(_scientificNameController, 'Ylmy ady', Icons.science),
              _buildTextField(_descriptionController, 'Düşündiriş', Icons.description, maxLines: 3),
              _buildTextField(_medicalUsesController, 'Peýdasy', Icons.healing, maxLines: 3),
              _buildTextField(_usedPartController, 'Ulanylýan bölegi', Icons.list),
              _buildTextField(_preparationMethodController, 'Taýýarlanyş usuly', Icons.local_cafe, maxLines: 3),
              _buildTextField(_relatedDiseasesController, 'Degişli keseller', Icons.sick, maxLines: 2),
              _buildTextField(_chemicalCompositionController, 'Himiki düzümi', Icons.biotech, maxLines: 2),
              _buildTextField(_contraindicationsController, 'Garşy görkezmeler', Icons.warning, maxLines: 2),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _imageUrl.isNotEmpty
          ? PlantImage(imageUrl: _imageUrl, borderRadius: 20)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, size: 50, color: Theme.of(context).primaryColor),
                const SizedBox(height: 10),
                const Text('Surat goşmak üçin basyň'),
              ],
            ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bu ýeri doldurmagyňyz zerur';
          }
          return null;
        },
      ),
    );
  }
}
