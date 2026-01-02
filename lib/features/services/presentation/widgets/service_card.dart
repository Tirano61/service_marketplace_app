import 'package:flutter/material.dart';
import '../../domain/entities/service.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final bool showActions;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del servicio
            if (service.images.isNotEmpty)
              Stack(
                children: [
                  Image.network(
                    service.images.first,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      );
                    },
                  ),
                  // Badge de estado
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: service.isActive
                            ? Colors.green
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        service.isActive ? 'Activo' : 'Pausado',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 180,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y categoría
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Categoría
                  Chip(
                    label: Text(
                      service.categoryName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[50],
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Descripción
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Info adicional
                  Row(
                    children: [
                      // Precio
                      if (service.price != null) ...[
                        Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '\$${service.price!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ] else ...[
                        Chip(
                          label: const Text('A convenir', style: TextStyle(fontSize: 11)),
                          backgroundColor: Colors.orange[50],
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 16),
                      ],
                      
                      // Cobertura
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${service.coverageRadiusKm.toStringAsFixed(0)} km',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      
                      const Spacer(),
                      
                      // Rating
                      if (service.reviewCount > 0) ...[
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${service.rating.toStringAsFixed(1)} (${service.reviewCount})',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ] else
                        Text(
                          'Sin reseñas',
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                    ],
                  ),
                  
                  // Botones de acción
                  if (showActions) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onToggleStatus != null)
                          TextButton.icon(
                            onPressed: onToggleStatus,
                            icon: Icon(
                              service.isActive ? Icons.pause : Icons.play_arrow,
                              size: 18,
                            ),
                            label: Text(service.isActive ? 'Pausar' : 'Activar'),
                          ),
                        if (onEdit != null)
                          TextButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Editar'),
                          ),
                        if (onDelete != null)
                          TextButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
