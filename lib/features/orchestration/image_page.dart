import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/features/orchestration/providers/image_provider.dart';
import 'package:onepanelapp_app/features/orchestration/widgets/image_card.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DockerImageProvider>().loadImages();
    });
  }

  Future<void> _showPullDialog(BuildContext context) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.orchestrationPullImage),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.orchestrationPullImageHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      final provider = context.read<DockerImageProvider>();
      
      String image = result;
      String? tag;
      if (result.contains(':')) {
        final parts = result.split(':');
        image = parts[0];
        tag = parts.sublist(1).join(':');
      }
      
      final success = await provider.pullImage(image, tag: tag);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? l10n.orchestrationPullSuccess 
              : l10n.orchestrationPullFailed),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Consumer<DockerImageProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.images.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.commonLoadFailedTitle),
                  Text(provider.error!),
                  ElevatedButton(
                    onPressed: () => provider.loadImages(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            );
          }

          if (provider.images.isEmpty) {
            return Center(child: Text(l10n.commonEmpty));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadImages(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.images.length,
              itemBuilder: (context, index) {
                final image = provider.images[index];
                return ImageCard(image: image);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPullDialog(context),
        child: const Icon(Icons.download),
      ),
    );
  }
}
