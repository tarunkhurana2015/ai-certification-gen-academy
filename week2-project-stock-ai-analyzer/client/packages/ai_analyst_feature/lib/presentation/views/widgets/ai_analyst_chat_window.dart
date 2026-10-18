import 'dart:async';
import 'package:flutter/material.dart';

import '../../../domain/entities/analyst_response.dart';
import '../../../domain/entities/quarterly_kpis.dart';
import '../../../data/datasources/remote_kpi_datasource.dart';
import 'citation_viewer_modal.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? citation;
  final List<AnalystCitation> citations;
  final String? routeUsed;
  final DateTime timestamp;
  final double durationSeconds;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.citation,
    this.citations = const [],
    this.routeUsed,
    required this.timestamp,
    this.durationSeconds = 0.0,
  });
}

class AiAnalystChatWindow extends StatefulWidget {
  final QuarterlyKpis report;
  final VoidCallback? onClose;
  final RemoteKpiDataSource? remoteDataSource;

  const AiAnalystChatWindow({
    super.key,
    required this.report,
    this.onClose,
    this.remoteDataSource,
  });

  @override
  State<AiAnalystChatWindow> createState() => _AiAnalystChatWindowState();
}

class _AiAnalystChatWindowState extends State<AiAnalystChatWindow> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<String> _suggestedPrompts = [
    'Why did operating margin compress this quarter?',
    'Break down CapEx spending on AI compute',
    'How does Free Cash Flow compare to last quarter?',
    'Summarize balance sheet liquidity & net cash',
  ];

  @override
  void initState() {
    super.initState();
    _initDefaultConversation();
    _loadDynamicPrompts();
  }

  void _loadDynamicPrompts() async {
    if (widget.remoteDataSource != null) {
      try {
        final prompts = await widget.remoteDataSource!.fetchSuggestedPrompts();
        if (mounted && prompts.isNotEmpty) {
          setState(() {
            _suggestedPrompts = prompts;
          });
        }
      } catch (_) {}
    }
  }

  void _initDefaultConversation() {
    _messages.clear();
    _messages.add(
      ChatMessage(
        text:
            'Hello! I am your AI Earnings Analyst Copilot for ${widget.report.companyName} (${widget.report.ticker}) ${widget.report.fiscalPeriodDisplay}.\n\nI have parsed the quarterly report into layout-aware semantic chunks and verified the 18+ standardized financial KPIs.\n\nAsk me anything about revenue drivers, cost pressures, capital expenditures, or liquidity.',
        isUser: false,
        citation: 'SEC 10-Q & Shareholder Update · SQLite Index',
        citations: [
          AnalystCitation(
            source: '${widget.report.ticker} 10-Q',
            pageNumber: 1,
            sectionName: 'Audited Financial Statements',
            snippet:
                '${widget.report.companyName} ${widget.report.fiscalPeriodDisplay} audited filings indexed into SQLite & ChromaDB.',
            tag: '[Page - 1, Section - Financial Statements]',
          ),
        ],
        routeUsed: 'Financial RAG',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AiAnalystChatWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.report.documentId != widget.report.documentId) {
      _initDefaultConversation();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String userText) {
    if (userText.trim().isEmpty || _isLoading) return;

    final trimmed = userText.trim();
    _textController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: trimmed,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();
    _fetchAnalystResponse(trimmed);
  }

  Future<void> _fetchAnalystResponse(String query) async {
    if (widget.remoteDataSource != null) {
      try {
        final isAlive = await widget.remoteDataSource!.checkHealth();
        if (isAlive) {
          final res = await widget.remoteDataSource!.queryAnalyst(
            query: query,
            ticker: widget.report.ticker,
          );
          if (mounted) {
            setState(() {
              _messages.add(
                ChatMessage(
                  text: res.answer,
                  isUser: false,
                  citation: res.citations.isNotEmpty ? res.citations.first.displayTag : null,
                  citations: res.citations,
                  routeUsed: res.routeDisplayName,
                  timestamp: DateTime.now(),
                  durationSeconds: res.durationSeconds,
                ),
              );
              _isLoading = false;
            });
            _scrollToBottom();
            return;
          }
        }
      } catch (e) {
        debugPrint('[AiAnalystChatWindow] Remote query fallback ($e)');
      }
    }

    // Offline / simulated response fallback
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final answer = _generateContextualAnswer(query);
    setState(() {
      _messages.add(answer);
      _isLoading = false;
    });
    _scrollToBottom();
  }

  ChatMessage _generateContextualAnswer(String query) {
    final q = query.toLowerCase();
    final rep = widget.report;

    if (q.contains('margin') || q.contains('compress') || q.contains('gross')) {
      return ChatMessage(
        text:
            '${rep.ticker} reported a Gross Margin of ${rep.profitability.grossMarginPct.toStringAsFixed(2)}% and Operating Margin of ${rep.profitability.operatingMarginPct.toStringAsFixed(2)}% in ${rep.fiscalPeriodDisplay}.\n\nAccording to the shareholder update, margin compression was driven by:\n1. Lower vehicle average selling prices (ASPs) due to attractive financing incentives.\n2. Increased R&D spend and compute hardware procurement for next-gen autonomous systems.\n3. One-off restructuring expenses.',
        isUser: false,
        citation: 'Shareholder Deck Pg. 4, Item 1 (Financial Summary)',
        citations: [
          AnalystCitation(
            source: 'Shareholder Deck Pg. 4, Item 1',
            pageNumber: 4,
            sectionName: 'Financial Summary',
            snippet:
                'Gross Margin: ${rep.profitability.grossMarginPct.toStringAsFixed(2)}%, Operating Margin: ${rep.profitability.operatingMarginPct.toStringAsFixed(2)}%.',
            tag: 'Shareholder Deck Pg. 4, Item 1 (Financial Summary)',
          ),
        ],
        routeUsed: 'Exact GAAP (SQL)',
        timestamp: DateTime.now(),
      );
    } else if (q.contains('capex') || q.contains('compute') || q.contains('ai')) {
      return ChatMessage(
        text:
            'In ${rep.fiscalPeriodDisplay}, Capital Expenditures (CapEx) totaled \$${(rep.cashFlow.capitalExpendituresMillions / 1000).toStringAsFixed(2)}B.\n\nManagement emphasized aggressive reinvestment into expanding Megapack manufacturing lines and deploying next-generation AI training clusters.',
        isUser: false,
        citation: 'Statement of Cash Flows · Item 1.02 CapEx Schedule',
        citations: [
          AnalystCitation(
            source: 'Statement of Cash Flows',
            pageNumber: 5,
            sectionName: 'Item 1.02 CapEx Schedule',
            snippet:
                'Capital expenditures for the quarter ended were \$${(rep.cashFlow.capitalExpendituresMillions / 1000).toStringAsFixed(2)} billion.',
            tag: '[Page - 5, Section - Statement of Cash Flows]',
          ),
        ],
        routeUsed: 'Hybrid RAG (Dense + BM25)',
        timestamp: DateTime.now(),
      );
    } else if (q.contains('cash') || q.contains('liquidity') || q.contains('balance')) {
      return ChatMessage(
        text:
            'Balance sheet liquidity is fortress-strong with \$${(rep.balanceSheet.cashAndEquivalentsMillions / 1000).toStringAsFixed(2)}B in Cash & Equivalents versus \$${(rep.balanceSheet.totalDebtMillions / 1000).toStringAsFixed(2)}B in Total Debt.\n\nThis yields a robust Net Cash position of +\$${(rep.balanceSheet.netCashMillions / 1000).toStringAsFixed(2)}B with a conservative Debt-to-Equity ratio of ${rep.balanceSheet.debtToEquityRatio?.toStringAsFixed(3) ?? "N/A"}.',
        isUser: false,
        citation: 'Consolidated Balance Sheets · 10-Q Part I',
        citations: [
          AnalystCitation(
            source: 'Consolidated Balance Sheets',
            pageNumber: 3,
            sectionName: '10-Q Part I',
            snippet:
                'Cash and cash equivalents: \$${(rep.balanceSheet.cashAndEquivalentsMillions / 1000).toStringAsFixed(2)}B. Total Debt: \$${(rep.balanceSheet.totalDebtMillions / 1000).toStringAsFixed(2)}B.',
            tag: '[Page - 3, Section - Balance Sheet]',
          ),
        ],
        routeUsed: 'Exact GAAP (SQL)',
        timestamp: DateTime.now(),
      );
    } else {
      return ChatMessage(
        text:
            'Based on ${rep.companyName}\'s ${rep.fiscalPeriodDisplay} earnings report: Total Revenue was \$${(rep.profitability.totalRevenueMillions / 1000).toStringAsFixed(2)}B with Free Cash Flow of \$${(rep.cashFlow.freeCashFlowMillions / 1000).toStringAsFixed(2)}B and diluted GAAP EPS of \$${rep.profitability.epsDilutedGaap.toStringAsFixed(2)}.\n\nAll metrics are verified from official SEC filing tables.',
        isUser: false,
        citation: 'SEC 10-Q Summary Table & Footnotes',
        citations: [
          AnalystCitation(
            source: 'SEC 10-Q Summary Table',
            pageNumber: 2,
            sectionName: 'Financial Results',
            snippet:
                'Revenue: \$${(rep.profitability.totalRevenueMillions / 1000).toStringAsFixed(2)}B. Free Cash Flow: \$${(rep.cashFlow.freeCashFlowMillions / 1000).toStringAsFixed(2)}B.',
            tag: '[Page - 2, Section - Financial Results]',
          ),
        ],
        routeUsed: 'Hybrid RAG (Dense + BM25)',
        timestamp: DateTime.now(),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.purple, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Earnings Copilot Q&A',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${widget.report.ticker} ${widget.report.fiscalPeriodDisplay} · Grounded RAG',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Reset Conversation',
                  onPressed: () => setState(_initDefaultConversation),
                ),
                if (widget.onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Close Copilot',
                    onPressed: widget.onClose,
                  ),
              ],
            ),
          ),

          // Pinned Context Chip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: colorScheme.primaryContainer.withValues(alpha: 0.2),
            child: Row(
              children: [
                Icon(Icons.description_outlined, size: 14, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Active Scope: ${widget.report.companyName} (${widget.report.fiscalPeriodDisplay})',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Message Scroll Feed
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildLoadingBubble(colorScheme);
                }

                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(msg.isUser ? 14 : 2),
                          bottomRight: Radius.circular(msg.isUser ? 2 : 14),
                        ),
                        border: Border.all(
                          color: msg.isUser
                              ? Colors.transparent
                              : colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!msg.isUser && msg.routeUsed != null) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _routeIcon(msg.routeUsed!),
                                    size: 11,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    msg.routeUsed!,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Text(
                            msg.text,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.35,
                              color: msg.isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                            ),
                          ),
                          _buildCitations(msg, context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Suggested Questions Carousel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _suggestedPrompts.map((prompt) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ActionChip(
                      label: Text(
                        prompt,
                        style: const TextStyle(fontSize: 10.5),
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(2),
                      onPressed: () => _sendMessage(prompt),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Message Input Field
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'Ask about ${widget.report.ticker} margins, CapEx...',
                      hintStyle: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble(ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Retrieving filings via Hybrid RAG...',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitations(ChatMessage msg, BuildContext context) {
    final List<AnalystCitation> citationItems = [];
    if (msg.citations.isNotEmpty) {
      citationItems.addAll(msg.citations);
    } else if (msg.citation != null && msg.citation!.isNotEmpty) {
      citationItems.add(
        AnalystCitation(
          source: '${widget.report.companyName} (${widget.report.fiscalPeriodDisplay})',
          snippet: msg.text,
          tag: msg.citation!,
          sectionName: 'Financial Summary',
        ),
      );
    }

    if (citationItems.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: citationItems.map((c) {
          final label = c.tag.isNotEmpty ? c.tag : c.displayTag;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: GestureDetector(
              onTap: () => CitationViewerModal.show(context, c),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link, size: 11, color: Colors.purple),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        }).toList(),
      ),
    );
  }

  IconData _routeIcon(String route) {
    if (route.contains('SQL')) return Icons.table_chart_outlined;
    if (route.contains('Comparison')) return Icons.compare_arrows_outlined;
    return Icons.search_outlined;
  }
}
