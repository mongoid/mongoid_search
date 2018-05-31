Releasing Mongoid::Search
========================

There're no particular rules about when to release mongoid-search. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

### Release

Run tests, check that all tests succeed locally.

```
bundle install
bundle exec rake
```

Check that the last build succeeded in [Travis CI](https://travis-ci.org/mongoid/mongoid-search) for all supported platforms.

Increment the version, modify [lib/mongoid/search/version.rb](lib/mongoid/search/version.rb).

*  Increment the third number if the release has bug fixes and/or very minor features, only (eg. change `0.5.1` to `0.5.2`).
*  Increment the second number if the release contains major features or breaking API changes (eg. change `0.5.1` to `0.4.0`).

Change "Next Release" in [CHANGELOG.md](CHANGELOG.md) to the new version.

```
### 0.4.0 (2018-01-01)
```

Remove the line with "Your contribution here.", since there will be no more contributions to this release.

Commit your changes.

```
git add CHANGELOG.md lib/mongoid/search/version.rb
git commit -m "Preparing for release, 0.4.0."
git push origin master
```

Release.

```
$ rake release

mongoid-search 0.4.0 built to pkg/mongoid-search-0.4.0.gem.
Tagged v0.4.0.
Pushed git commits and tags.
Pushed mongoid-search 0.4.0 to rubygems.org.
```

### Prepare for the Next Version

Add the next release to [CHANGELOG.md](CHANGELOG.md).

```
### 0.4.1 (Next)

* Your contribution here.
```

Increment the minor version, modify [lib/mongoid/search/version.rb](lib/mongoid/search/version.rb).

Commit your changes.

```
git add CHANGELOG.md lib/mongoid/search/version.rb
git commit -m "Preparing for next release, 0.4.1."
git push origin master
```
