import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../models/document_model.dart';
import '../providers/documents_provider.dart';
import '../widgets/neuron_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_dialogs.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Document', 'Note', 'Code', 'Project'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docsProv = context.watch<DocumentsProvider>();
    final docs = docsProv.filteredDocuments;
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        leading: !isDesktop
            ? Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, size: 24),
                  tooltip: 'Open Menu',
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : null,
        title: const Text(
          'Knowledge Base',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          PopupMenuButton<DocumentSort>(
            icon: const Icon(Icons.sort, size: 22),
            tooltip: 'Sort Documents',
            onSelected: (sort) => docsProv.setSort(sort),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DocumentSort.recentlyModified,
                child: Text('Recently Modified'),
              ),
              const PopupMenuItem(
                value: DocumentSort.titleAsc,
                child: Text('Title (A-Z)'),
              ),
              const PopupMenuItem(
                value: DocumentSort.source,
                child: Text('Source'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            tooltip: 'Add Document',
            onPressed: () => AppDialogs.showDocumentSheet(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: Column(
            children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => docsProv.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search title, content, or #tags...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          docsProv.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = docsProv.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => docsProv.setCategory(cat),
                    backgroundColor: AppTheme.card(context),
                    selectedColor: AppColors.primary.withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryLight : AppTheme.secondaryText(context),
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppTheme.border(context),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Documents List
          Expanded(
            child: docs.isEmpty
                ? EmptyState(
                    icon: Icons.folder_open,
                    title: 'No Documents Found',
                    description: _searchController.text.isNotEmpty
                        ? 'No documents match "${_searchController.text}". Try a different search term.'
                        : 'Your knowledge base is empty in this category. Add your first note or document.',
                    actionLabel: 'Add Document',
                    onAction: () => AppDialogs.showDocumentSheet(context),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ...docs.map((doc) => _buildDocumentCard(context, doc, docsProv)),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    ),
  ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AppDialogs.showDocumentSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Document', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    DocumentModel doc,
    DocumentsProvider provider,
  ) {
    Color typeColor;
    IconData typeIcon;

    switch (doc.type.toLowerCase()) {
      case 'code':
        typeColor = AppColors.blue;
        typeIcon = Icons.code;
        break;
      case 'note':
        typeColor = AppColors.success;
        typeIcon = Icons.note_outlined;
        break;
      case 'project':
        typeColor = AppColors.secondaryPurple;
        typeIcon = Icons.folder_outlined;
        break;
      case 'document':
      default:
        typeColor = AppColors.error;
        typeIcon = Icons.picture_as_pdf;
        break;
    }

    final dateStr = DateFormat('MMM d, y').format(doc.modifiedAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeuronCard(
        padding: const EdgeInsets.all(16),
        onTap: () => AppDialogs.showDocumentDetail(context, doc),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, size: 18, color: typeColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryText(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${doc.source} • $dateStr',
                        style: TextStyle(fontSize: 11, color: AppTheme.secondaryText(context)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    doc.isPinned ? Icons.star : Icons.star_border,
                    size: 20,
                    color: doc.isPinned ? AppColors.warning : AppTheme.secondaryText(context),
                  ),
                  tooltip: doc.isPinned ? 'Unpin' : 'Pin',
                  onPressed: () => provider.togglePin(doc.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                  tooltip: 'Delete',
                  onPressed: () {
                    AppDialogs.showConfirmDialog(
                      context,
                      title: 'Delete Document?',
                      message: 'Are you sure you want to delete "${doc.title}"?',
                      confirmLabel: 'Delete',
                      isDestructive: true,
                      onConfirm: () => provider.deleteDocument(doc.id),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              doc.content,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppTheme.secondaryText(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (doc.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: doc.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.cardElevated(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border(context)),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(fontSize: 10, color: AppTheme.secondaryText(context)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
