import 'package:flutter/material.dart';
import 'package:onepanelapp_app/core/config/api_config.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/core/theme/app_design_tokens.dart';
import 'package:onepanelapp_app/features/server/server_repository.dart';

class ServerFormPage extends StatefulWidget {
  const ServerFormPage({super.key});

  @override
  State<ServerFormPage> createState() => _ServerFormPageState();
}

class _ServerFormPageState extends State<ServerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _repository = const ServerRepository();

  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = context.l10n;
    setState(() {
      _saving = true;
    });

    try {
      final config = ApiConfig(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        url: _urlController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        isDefault: true,
      );

      await _repository.saveConfig(config);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.serverFormSaveSuccess)),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.serverFormSaveFailed(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.serverFormTitle)),
      body: SingleChildScrollView(
        padding: AppDesignTokens.pagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.serverFormName,
                  hintText: l10n.serverFormNameHint,
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.serverFormRequired
                    : null,
              ),
              const SizedBox(height: AppDesignTokens.spacingLg),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: l10n.serverFormUrl,
                  hintText: l10n.serverFormUrlHint,
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.serverFormRequired
                    : null,
              ),
              const SizedBox(height: AppDesignTokens.spacingLg),
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: l10n.serverFormApiKey,
                  hintText: l10n.serverFormApiKeyHint,
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.serverFormRequired
                    : null,
              ),
              const SizedBox(height: AppDesignTokens.spacingLg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.serverFormTestHint)),
                    );
                  },
                  child: Text(l10n.serverFormTest),
                ),
              ),
              const SizedBox(height: AppDesignTokens.spacingMd),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.serverFormSaveConnect),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
