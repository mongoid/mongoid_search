# Upgrading

## Upgrading to 0.6.0

### Relevance search returns highest-relevance results first

Searches with `relevant_search: true`, or with `Mongoid::Search.relevant_search = true`, now return results sorted by **decreasing numeric relevance**. Previously, results were sorted in ascending order, putting lower scores first; the map-reduce reducer could also return arrays instead of numeric scores. Relevance scores are now numeric counts of matching indexed keywords.

For example, a search matching documents with relevance scores of `1` and `2` now returns the document with score `2` first:

```ruby
Product.full_text_search('amazing apple', relevant_search: true).map(&:relevance)
# => [2.0, 1.0]
```

Remove any application-side `.reverse` or other sorting workaround used to put the most relevant results first. If your application intentionally needs the least relevant results first, sort the returned array explicitly:

```ruby
Product.full_text_search('amazing apple', relevant_search: true).sort_by(&:relevance)
```

Relevance search still returns an `Array`, not a Mongoid criteria. Searches with relevance disabled (the default) are unaffected. No keyword reindexing is needed.
