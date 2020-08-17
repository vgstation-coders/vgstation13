This ugly mess is the changelog generator originally made by N3X15 for /vg/station and now used widely throughout SS13's community.

It has been updated in late 2019 for general code cleanup and to add better templating options.

You are free to copy, use, and modify it under the terms of the MIT License agreement.

## Prerequisites

* Python &gt;= 3.6 - Sorry, Python2.7 is dead as of 2020. Buck up.
  * pyyaml &gt;= 5.1 - Older versions have a security vulnerability and are now incompatible.
  * jinja2 - Since we're already using pip, we might as well use an actual templating library
  * BeautifulSoup 4 - Only needed if you're upgrading ye olde HTML templates.

```shell
# To install most of these:
$ pip3.6 install -U pyyaml jinja2 beautifulsoup4
```

## Usage

```shell
$ python3.6 ss13_genchangelog.py --help
```
```
usage: ss13_genchangelog.py [-h] [-d] targetFile ymlDir

positional arguments:
  targetFile     The HTML changelog we wish to update.
  ymlDir         The directory of YAML changelogs we will use.

optional arguments:
  -h, --help     show this help message and exit
  -d, --dry-run  Only parse changelogs and, if needed, the targetFile. (A
                 .dry_changelog.yml will be output for debugging purposes.)
```

## Changelogs

Changelogs are fairly simple, by design:

```yaml
author: AUTHOR'S NAME
changes:
- rscadd: A thing I added
- rscdel: A thing I removed
- bugfix: A bugfix I made
```

The prefixes (`rscadd`, etc) correspond to CSS classes that add shit like icons to the front of the change entry to indicate what kind of change it was. For a list, see the top of [ss13_genchangelog.py](ss13_genchangelog.py).

### Validating Changelogs with Schemas
**NOTE:** This is for advanced users only.  You don't need to bother with this if you don't want to.

For Continuous Integration or IDE use, a [changelog schema](changelog.schema.yml) is available.

This is a JSON Schema represented as YAML and can be used with a tool like `pajv`:

```shell
# Install pajv with npm
sudo npm install -g pajv

# Validate a changelog with it
pajv -s tools/changelog/changelog.schema.yml -d html/changelogs/example.yml
```
```
html/changelogs/example.yml valid
```
