/// Domain entities for Financial Analyst AI Responses and Citation Grounding.

class AnalystCitation {
  final String source;
  final int pageNumber;
  final String sectionName;
  final String snippet;
  final String tag;

  const AnalystCitation({
    required this.source,
    this.pageNumber = 0,
    this.sectionName = 'Report',
    this.snippet = '',
    this.tag = '',
  });

  factory AnalystCitation.fromJson(Map<String, dynamic> json) {
    int parsedPage = 0;
    final rawPage = json['page_number'];
    if (rawPage is int) {
      parsedPage = rawPage;
    } else if (rawPage is String) {
      parsedPage = int.tryParse(rawPage) ?? 0;
    }

    return AnalystCitation(
      source: json['source']?.toString() ?? 'Filing',
      pageNumber: parsedPage,
      sectionName: json['section_name']?.toString() ??
          json['financial_domain']?.toString() ??
          'Report',
      snippet: json['snippet']?.toString() ?? json['text']?.toString() ?? '',
      tag: json['tag']?.toString() ?? json['citation']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'source': source,
        'page_number': pageNumber,
        'section_name': sectionName,
        'snippet': snippet,
        'tag': tag,
      };

  String get displayTag {
    if (tag.isNotEmpty) return tag;
    if (pageNumber > 0) return '[Page - $pageNumber, Section - $sectionName]';
    return '[$sectionName]';
  }
}

class AnalystAnswer {
  final String query;
  final String routeUsed; // 'sql_kpi', 'hybrid_rag', 'comparison'
  final String answer;
  final List<AnalystCitation> citations;
  final String? ticker;
  final String? financialDomain;
  final Map<String, dynamic>? rawData;
  final double durationSeconds;

  const AnalystAnswer({
    required this.query,
    required this.routeUsed,
    required this.answer,
    this.citations = const [],
    this.ticker,
    this.financialDomain,
    this.rawData,
    this.durationSeconds = 0.0,
  });

  factory AnalystAnswer.fromJson(Map<String, dynamic> json) {
    final rawCitations = json['citations'] as List<dynamic>? ?? [];
    return AnalystAnswer(
      query: json['query']?.toString() ?? '',
      routeUsed: json['route_used']?.toString() ?? 'hybrid_rag',
      answer: json['answer']?.toString() ?? '',
      citations: rawCitations
          .whereType<Map<String, dynamic>>()
          .map((c) => AnalystCitation.fromJson(c))
          .toList(),
      ticker: json['ticker']?.toString(),
      financialDomain: json['financial_domain']?.toString(),
      rawData: json['raw_data'] as Map<String, dynamic>?,
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'query': query,
        'route_used': routeUsed,
        'answer': answer,
        'citations': citations.map((c) => c.toJson()).toList(),
        if (ticker != null) 'ticker': ticker,
        if (financialDomain != null) 'financial_domain': financialDomain,
        if (rawData != null) 'raw_data': rawData,
        'duration_seconds': durationSeconds,
      };

  String get routeDisplayName {
    switch (routeUsed.toLowerCase()) {
      case 'sql_kpi':
        return 'Exact GAAP (SQL)';
      case 'hybrid_rag':
        return 'Hybrid RAG (Dense + BM25)';
      case 'comparison':
        return 'Peer Comparison';
      default:
        return 'Financial RAG';
    }
  }
}
