# Groonga output plugin for Embulk

TODO: Write short description here and embulk-output-groonga.gemspec file.

## Overview

* **Plugin type**: output
* **Load all or nothing**: no
* **Resume supported**: no
* **Cleanup supported**: yes

## Configuration

- **property1**: description (string, required)
- **property2**: description (integer, default: default-value)

## Example

```yaml
out:
  type: groonga
  property1: example1
  property2: example2
```


## Build

```
$ rake
```
