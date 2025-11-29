import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

/// Página de debug para verificar por qué no aparecen las imágenes
class ImageDebugPage extends StatefulWidget {
  const ImageDebugPage({super.key});

  @override
  State<ImageDebugPage> createState() => _ImageDebugPageState();
}

class _ImageDebugPageState extends State<ImageDebugPage> {
  List<Post> _posts = [];
  bool _isLoading = false;
  String _debugInfo = '';

  @override
 void initState() {
    super.initState();
    _loadPostsAndDebug();
  }

  Future<void> _loadPostsAndDebug() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Cargando posts...\n';
    });

    try {
      final posts = await ApiService.getPosts();
      
      StringBuffer debug = StringBuffer();
      debug.writeln('✅ Posts cargados exitosamente');
      debug.writeln('📊 Total de posts: ${posts.length}\n');
      
      for (var i = 0; i < posts.length; i++) {
        final post = posts[i];
        debug.writeln('--- POST ${i + 1}: ${post.title} ---');
        debug.writeln('  ID: ${post.id}');
        debug.writeln('  Role: ${post.role} (${post.roleText})');
        debug.writeln('  imageUrl field: ${post.imageUrl}');
        debug.writeln('  imageUrl is null: ${post.imageUrl == null}');
        debug.writeln('  imageUrl is empty: ${post.imageUrl?.isEmpty ?? "N/A"}');
        
        if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
          final fullUrl = ApiService.getFullImageUrl(post.imageUrl);
          debug.writeln('  ✅ TIENE IMAGEN');
          debug.writeln('  Full URL: $fullUrl');
        } else {
          debug.writeln('  ❌ NO TIENE IMAGEN');
        }
        debug.writeln('');
      }
      
      setState(() {
        _posts = posts;
        _debugInfo = debug.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = '❌ ERROR: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug de Imágenes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPostsAndDebug,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _debugInfo,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Posts con imagen:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ..._posts.where((p) => p.imageUrl != null && p.imageUrl!.isNotEmpty).map(
                        (post) => Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('URL: ${post.imageUrl}'),
                                Text('Full: ${ApiService.getFullImageUrl(post.imageUrl)}'),
                                const SizedBox(height: 8),
                                Image.network(
                                  ApiService.getFullImageUrl(post.imageUrl),
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.red[100],
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        'ERROR al cargar imagen:\n$error',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
    );
  }
}
