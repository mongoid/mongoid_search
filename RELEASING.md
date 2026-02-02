Releasing Mongoid::Search
========================

There're no particular rules about when to release mongoid-search. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

### Release

Run tests, check that all tests succeed locally.

```
bundle install
bundle exec rake
```

Check that the last build succeeded in [GitHub Actions](https://github.com/mongoid/mongoid_search/actions) for all supported platforms.

Change "Next Release" in [CHANGELOG.md](CHANGELOG.md) to the new version.

```
### 0.6.0 (2026-02-02)
```

Remove the line with "Your contribution here.", since there will be no more contributions to this release.

Commit your changes.

```
git add CHANGELOG.md
git commit -m "Preparing for release, 0.6.0."
git push origin master
```

Release.

```
$ bundle exec rake release

mongoid_search 0.6.0 built to pkg/mongoid_search-0.6.0.gem.
Tagged v0.6.0.
Pushed git commits and tags.
Pushed mongoid_search 0.6.0 to rubygems.org.
```

**Note:** You must have RubyGems credentials configured and push permissions for the `mongoid_search` gem. If you haven't authenticated yet, run `gem signin` first.

### Prepare for the Next Version

Add the next release to [CHANGELOG.md](CHANGELOG.md).

```
### 0.6.0 (Next)

* Your contribution here.
```

Increment the minor version, modify [mongoid_search.gemspec](mongoid_search.gemspec).

Commit your changes.

```
git add CHANGELOG.md mongoid_search.gemspec
git commit -m "Preparing for next release, 0.6.0."
git push origin master
```

Major version numbers are incremented with the first new feature.
