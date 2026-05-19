import '../content/legal_content.dart';

/// Builds plain-text legal documents for copy, share, or web hosting.
class LegalTextBuilder {
  LegalTextBuilder._();

  static String document(LegalDocumentType type) {
    final doc = LegalContent.document(type);
    return _format(doc.title, doc.sections);
  }

  static String allPoliciesForHosting() {
    final buffer = StringBuffer();
    for (final type in LegalDocumentType.values) {
      if (type == LegalDocumentType.playStoreChecklist) continue;
      buffer.writeln(document(type));
      buffer.writeln('\n${'=' * 60}\n');
    }
    return buffer.toString().trim();
  }

  static String _format(String title, List<LegalSection> sections) {
    final buffer = StringBuffer('$title\n\n');
    for (final s in sections) {
      buffer.writeln(s.heading);
      buffer.writeln(s.body);
      buffer.writeln();
    }
    return buffer.toString().trim();
  }
}
