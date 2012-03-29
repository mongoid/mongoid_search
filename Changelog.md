## 0.3.0 HEAD
* Fix keyword stemming working even if stem\_keywords is set to false.
* Depend on Mongoid 2.x
* Remove bson\_ext dependency (C-extension)

## 0.3.0.beta.2

* Update readme.
* Autodetect stemming library.

## 0.3.0.beta.1

* Support multiple stemming libraries
* Namespace all common-named internal constants so that they do not conflict with yours.
* Fix relevant\_search and stem\_keywords options taking wrong values.
* Fix ActiveSupport deprecation warning
* Make search case-insensitive for utf-8 strings.
