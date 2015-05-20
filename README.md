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
- **port**: groonga port (integer, default: 10043)
- **protocol**: connection protocol gqtp or http, (string, default: gqtp )


## Installation

* install embulk command isself.
* install groonga-command-parser with json-stream gem
* install embulk-output-groonga.

### Embulk install

install [embulk](https://github.com/embulk/embulk#quick-start)

### install groonga-command-parser with json-stream.

The original groonga-comand-parser depend on yajl-ruby.
However, yajl-ruby does not work on jruby environment.
(Embulk is written by jruby).
That is why, I rewrote groonga-command-parser .

```
git clone https://github.com/hiroyuki-sato/groonga-command-parser.git
cd groonga-command-parser/
git checkout json-stream
rake build
embulk gem install pkg/groonga-command-parser-1.0.4.gem
```

Finally install embulk-output-groonga

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
  port: 10043
  protocol: gqtp
```
