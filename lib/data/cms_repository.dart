import 'dart:convert';

import 'package:flutter/services.dart';

import 'models.dart';

/// Content source for titles, daily editorial and the reference library.
///
/// In production this is a headless CMS (Sanity, Strapi or Payload) behind a
/// cached JSON endpoint, so editors publish daily pieces and new titles without
/// an app release. The POC reads the same payload shape from a bundled asset.
class CmsRepository {
  CmsRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;

  Future<Catalog> fetchCatalog() async {
    final raw = await _bundle.loadString('assets/cms/catalog.json');
    return Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Ranked search over titles, daily pieces and reference entries.
  List<SearchHit> search(Catalog c, String query, {String filter = 'all'}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final words = q.split(RegExp(r'\s+'));
    int score(List<String> fields) {
      var s = 0;
      for (final w in words) {
        for (var i = 0; i < fields.length; i++) {
          if (fields[i].toLowerCase().contains(w)) s += i == 0 ? 3 : 1;
        }
      }
      return s;
    }

    final hits = <(int, SearchHit)>[];
    for (final r in c.reference) {
      final s = score([r.title, r.summary, ...r.body, ...r.seeAlso]);
      if (s > 0) hits.add((s + 2, SearchHit(kind: 'reference', id: r.id, title: '${r.title} (${r.year})', subtitle: r.summary, image: r.photo)));
    }
    for (final t in c.titles) {
      final s = score([t.title, t.author, t.blurb, ...t.genres]);
      if (s == 0) continue;
      final kind = t.isEbook ? 'ebook' : 'audiobook';
      final sub = t.isEbook ? '${t.author} · ${t.pages} pages' : '${t.author} · ${t.audioLength}';
      hits.add((s, SearchHit(kind: kind, id: t.id, title: t.title, subtitle: sub, image: t.cover)));
    }
    for (final d in c.daily) {
      final s = score([d.title, d.author, ...d.body]);
      if (s > 0) hits.add((s, SearchHit(kind: 'daily', id: d.id, title: d.title, subtitle: '${d.author} · ${d.minutes} min read', image: d.hero)));
    }
    hits.sort((a, b) => b.$1.compareTo(a.$1));
    return [
      for (final h in hits)
        if (filter == 'all' || h.$2.kind == filter) h.$2,
    ];
  }
}
