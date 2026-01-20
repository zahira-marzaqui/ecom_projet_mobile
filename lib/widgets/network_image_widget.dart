import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      debugPrint('⚠️ NetworkImageWidget: URL vide');
      return _buildErrorWidget('URL vide');
    }

    final trimmedUrl = imageUrl.trim();
    
    if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
      debugPrint('⚠️ NetworkImageWidget: URL invalide: $trimmedUrl');
      return _buildErrorWidget('URL invalide');
    }

    debugPrint('🖼️ Tentative de chargement: $trimmedUrl');

    return Image.network(
      trimmedUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          debugPrint('✅ Image chargée avec succès: $trimmedUrl');
          return child;
        }
        final totalBytes = loadingProgress.expectedTotalBytes;
        final loadedBytes = loadingProgress.cumulativeBytesLoaded;
        final progress = totalBytes != null && totalBytes > 0
            ? loadedBytes / totalBytes
            : null;
        if (progress != null) {
          final percent = (progress * 100).toStringAsFixed(1);
          debugPrint('📥 Chargement en cours: $percent% - $trimmedUrl');
        }
        return Container(
          color: const Color(0xFFF5F5F5),
          child: Center(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF000000),
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Erreur Image.network pour $trimmedUrl');
        debugPrint('   Type d\'erreur: ${error.runtimeType}');
        debugPrint('   Message: $error');
        if (stackTrace != null) {
          debugPrint('   StackTrace: $stackTrace');
        }
        
        String errorMessage = 'Erreur de chargement';
        final errorString = error.toString();
        if (errorString.contains('SocketException') || 
            errorString.contains('Failed host lookup')) {
          errorMessage = 'Pas de connexion';
        } else if (errorString.contains('TimeoutException')) {
          errorMessage = 'Timeout';
        } else if (errorString.contains('HttpException')) {
          errorMessage = 'Erreur HTTP';
        }
        
        return _buildErrorWidget(errorMessage);
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          debugPrint('✅ Image chargée de manière synchrone: $trimmedUrl');
          return child;
        }
        if (frame != null) {
          debugPrint('✅ Image chargée (frame): $trimmedUrl');
          return child;
        }
        return Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF000000),
              ),
            ),
          ),
        );
      },
      headers: const {
        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported,
            size: 48,
            color: Color(0xFF999999),
          ),
          const SizedBox(height: 8),
          const Text(
            'Image non disponible',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
