# Groonga output plugin for Embulk

Embulk output plugin to load insert data into groonga (full text search engine)

## Overview

* **Plugin type**: output
* **Load all or nothing**: no
* **Resume supported**: no
* **Cleanup supported**: yes

## Configuration

- **table**: output table name (string, required)
- **key_column**: this column convert column name into _key (string, required)
- **host**: groonga server name (string, rerquired)
- **port**: groonga port (integer, default: 10041)
- **protocol**: connection protocol gqtp or http, (string, default: http )


## Installation

* install embulk command isself.
* install embulk-output-groonga.

### Embulk install

install [embulk](https://github.com/embulk/embulk#quick-start)
For libyajl2 installation, *Embulk 0.6.10 required*.

### install gem from github master.

install embulk-output-groonga

```
git clone https://github.com/hiroyuki-sato/embulk-output-groonga.git
cd embulk-output-groonga
rake build
embulk gem install pkg/embulk-output-groonga-0.1.0.gem
```

## Example

Installation step are the following.

```yaml
out:
  type: groonga
  table: Site
  key_column: key
  host: localhost
  port: 10041
  protocol: http
```
