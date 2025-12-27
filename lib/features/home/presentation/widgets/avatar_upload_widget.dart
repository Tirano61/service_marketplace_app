import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../../core/theme/text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AvatarUploadWidget extends StatefulWidget {
  const AvatarUploadWidget({
    super.key,
    this.photoUrl,
    this.userName,
  });

  final String? photoUrl;
  final String? userName;

  @override
  State<AvatarUploadWidget> createState() => _AvatarUploadWidgetState();
}

class _AvatarUploadWidgetState extends State<AvatarUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;

  Future<void> _pickAndUploadImage() async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);

    try {
      // Mostrar opciones de cámara o galería con advertencia
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) {
        setState(() => _isPickingImage = false);
        return;
      }

      // Seleccionar imagen (sin restricciones iniciales de tamaño)
      final XFile? image = await _picker.pickImage(
        source: source,
      );

      if (image != null) {
        // Obtener tamaño del archivo original
        final originalFile = File(image.path);
        final originalSize = await originalFile.length();
        final maxSize = 5 * 1024 * 1024; // 5MB

        String finalPath = image.path;

        // Si la imagen es mayor a 5MB, comprimirla
        if (originalSize > maxSize) {
          if (mounted) {
            // Mostrar mensaje de que se está comprimiendo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Comprimiendo imagen...'),
                duration: Duration(seconds: 2),
              ),
            );
          }

          // Comprimir la imagen
          final compressedFile = await _compressImage(image.path, maxSize);
          
          if (compressedFile != null) {
            finalPath = compressedFile.path;
            final compressedSize = await compressedFile.length();
            
            if (mounted) {
              final originalMB = (originalSize / (1024 * 1024)).toStringAsFixed(2);
              final compressedMB = (compressedSize / (1024 * 1024)).toStringAsFixed(2);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Imagen comprimida de $originalMB MB a $compressedMB MB'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            // Si falla la compresión
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se pudo comprimir la imagen. Por favor, selecciona una imagen más pequeña.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
            setState(() => _isPickingImage = false);
            return;
          }
        }

        // Subir avatar
        if (mounted) {
          context.read<AuthBloc>().add(
                AuthUploadAvatarRequested(filePath: finalPath),
              );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  /// Comprime una imagen para que sea menor al tamaño máximo especificado
  Future<File?> _compressImage(String imagePath, int maxSizeBytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Comenzar con calidad 85 y reducirla gradualmente si es necesario
      int quality = 85;
      File? compressedFile;

      while (quality > 10) {
        final result = await FlutterImageCompress.compressAndGetFile(
          imagePath,
          targetPath,
          quality: quality,
          minWidth: 1024,
          minHeight: 1024,
        );

        if (result != null) {
          compressedFile = File(result.path);
          final size = await compressedFile.length();

          // Si el tamaño es aceptable, retornar
          if (size <= maxSizeBytes) {
            return compressedFile;
          }

          // Si aún es muy grande, reducir calidad
          quality -= 15;
        } else {
          break;
        }
      }

      return compressedFile;
    } catch (e) {
      debugPrint('Error al comprimir imagen: $e');
      return null;
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Advertencia sobre el tamaño
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Si la imagen supera 5 MB, será comprimida automáticamente',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.avatarUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avatar actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error al subir avatar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isUploading = state.status == AuthStatus.uploadingAvatar;

          return Center(
            child: Stack(
              children: [
                // Avatar circular
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                        ? Image.network(
                            widget.photoUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
                // Botón de editar
                if (!isUploading && !_isPickingImage)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                // Indicador de carga
                if (isUploading || _isPickingImage)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.2),
      child: Center(
        child: Text(
          _getInitials(widget.userName),
          style: TextStyles.h1.copyWith(
            color: Theme.of(context).primaryColor,
            fontSize: 48,
          ),
        ),
      ),
    );
  }
}
