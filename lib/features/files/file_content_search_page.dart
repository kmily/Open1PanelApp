import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/data/models/file_models.dart';
import 'package:onepanelapp_app/features/files/files_provider.dart';
import 'package:onepanelapp_app/features/files/file_preview_page.dart';

class FileContentSearchPage extends StatefulWidget {
  const FileContentSearchPage({super.key});

  @override
  State<FileContentSearchPage> createState() => _FileContentSearchPageState();
}

class _FileContentSearchPageState extends State<FileContentSearchPage> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  FileSearchResult? _result;
  String? _error;
  
  bool _caseSensitive = false;
  bool _wholeWord = false;
  bool _regex = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final provider = context.read<FilesProvider>();
      final result = await provider.searchInFiles(
        pattern: query,
        caseSensitive: _caseSensitive,
        wholeWord: _wholeWord,
        regex: _regex,
      );
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filesContentSearch),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.filesContentSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _isLoading ? null : _performSearch,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Aa'),
                      selected: _caseSensitive,
                      onSelected: (v) => setState(() => _caseSensitive = v),
                      tooltip: 'Case Sensitive',
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('\\b'),
                      selected: _wholeWord,
                      onSelected: (v) => setState(() => _wholeWord = v),
                      tooltip: 'Whole Word',
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('.*'),
                      selected: _regex,
                      onSelected: (v) => setState(() => _regex = v),
                      tooltip: 'Regex',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ),
            )
          else if (_result != null)
            Expanded(child: _buildResultsList(context, _result!)),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, FileSearchResult result) {
    if (result.matches.isEmpty) {
      return Center(child: Text(context.l10n.commonEmpty));
    }

    return ListView.builder(
      itemCount: result.matches.length,
      itemBuilder: (context, index) {
        final match = result.matches[index];
        return ListTile(
          title: Text(
            match.filePath.split('/').last,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.filePath,
                style: const TextStyle(fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${match.lineNumber}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Expanded(
                    child: Text(
                      match.line.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            final fileName = match.filePath.split('/').last;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FilePreviewPage(
                  filePath: match.filePath,
                  fileName: fileName,
                  initialLine: match.lineNumber,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
