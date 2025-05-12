#!/usr/bin/env python3
'''
Dependencies:
    Beautiful Soup 4 (for now)
    PyYAML
    Jinja2
Usage:
    $ python ss13_genchangelog.py [--dry-run] html/changelog.html html/changelogs/

ss13_genchangelog.py - Generate changelog from YAML.

Copyright (C) 2013-2019 Rob "N3X15" Nelson <nexisentertainment@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
'''

import sys
if sys.version_info[0] < 3:
    raise Exception("Must be using Python 3")
if sys.version_info.minor < 6:
    raise Exception("Must be using Python >= 3.6")

from time import time
import argparse
import collections
import datetime
import glob
import jinja2
import logging
import os
import yaml

# Valid entry types. Update changelog.schema.yml if you fuck with this.
VALID_PREFIXES = [
    'bugfix',
    'experiment',
    'imageadd',
    'imagedel',
    'rscadd',
    'rscdel',
    'soundadd',
    'sounddel',
    'spellcheck',
    'tgs',
    'tweak',
    'wip',
]

# So changelog isn't 5000 entries long
MAX_DATE_ENTRIES = 100

# Date format to use.
DATEFORMAT = "%Y.%m.%d"

def rebuild_changelog_from(old_changelog: str, all_changelog_entries: dict):
    from bs4 import BeautifulSoup
    #from bs4.element import NavigableString
    logging.info('Generating cache...')
    with open(old_changelog, 'r') as f:
        soup = BeautifulSoup(f, features='lxml')
        # Thankfully, old-style changelogs used a fairly standardized layout.
        for e in soup.find_all('div', {'class': 'commit'}):
            entry = {}
            # I love how redundant Python's STL is.
            date = datetime.datetime.strptime(e.h2.string.strip(), DATEFORMAT).date()  # key
            for authorT in e.find_all('h3', {'class': 'author'}):
                author = authorT.string
                # Strip suffix
                if author.endswith('updated:'):
                    author = author[:-8]
                author = author.strip()

                # Find <ul>
                ulT = authorT.next_sibling
                while(ulT.name != 'ul'):
                    ulT = ulT.next_sibling
                changes = []

                for changeT in ulT.children:
                    if changeT.name != 'li':
                        continue
                    val = changeT.decode_contents(formatter="html")
                    newdat = {changeT['class'][0] + '': val + ''}
                    if newdat not in changes:
                        changes += [newdat]

                if len(changes) > 0:
                    entry[author] = changes
            if date in all_changelog_entries:
                all_changelog_entries[date].update(entry)
            else:
                all_changelog_entries[date] = entry

def loadCache(changelog_cachefile):
    failed_cache_read = True
    all_changelog_entries = {}
    try:
        with open(changelog_cachefile) as f:
            (_, all_changelog_entries) = yaml.safe_load_all(f)
            failed_cache_read = False

            # Convert old timestamps to newer format.
            new_entries = {}
            for _date in all_changelog_entries.keys():
                ty = type(_date).__name__
                # print(ty)
                if ty in ['str', 'unicode']:
                    temp_data = all_changelog_entries[_date]
                    _date = datetime.datetime.strptime(_date, DATEFORMAT).date()
                    new_entries[_date] = temp_data
                else:
                    new_entries[_date] = all_changelog_entries[_date]
            all_changelog_entries = new_entries
    except Exception as e:
        logging.error("Failed to read cache:")
        logging.exception(e)
    return (failed_cache_read, all_changelog_entries)

def main():
    opt = argparse.ArgumentParser()
    opt.add_argument('-d', '--dry-run', dest='dryRun', default=False, action='store_true', help='Only parse changelogs and, if needed, the targetFile. (A .dry_changelog.yml will be output for debugging purposes.)')
    opt.add_argument('targetFile', help='The HTML changelog we wish to update.')
    opt.add_argument('ymlDir', help='The directory of YAML changelogs we will use.')

    args = opt.parse_args()

    today = datetime.date.today()

    all_changelog_entries = {}

    changelog_cache = os.path.join(args.ymlDir, '.all_changelog.yml')

    failed_cache_read = True
    if not args.dryRun:
        if os.path.isfile(changelog_cache):
            (failed_cache_read, all_changelog_entries) = loadCache(changelog_cache)
    else:
        changelog_cache = os.path.join(args.ymlDir, '.dry_changelog.yml')

    if failed_cache_read and os.path.isfile(args.targetFile):
        rebuild_changelog_from(args.targetFile, all_changelog_entries)

    del_after = []
    logging.info('Reading changelogs...')
    for fileName in glob.glob(os.path.join(args.ymlDir, "*.yml")):
        name, _ = os.path.splitext(os.path.basename(fileName))
        if name.startswith('.'):
            continue
        if name == 'example':
            continue
        fileName = os.path.abspath(fileName)
        logging.info('  Reading {}...'.format(fileName))
        cl = {}
        with open(fileName, 'r') as f:
            cl = yaml.safe_load(f)
            f.close()
        if today not in all_changelog_entries:
            all_changelog_entries[today] = {}
        author_entries = all_changelog_entries[today].get(cl['author'], [])
        if len(cl['changes']):
            new = 0
            for change in cl['changes']:
                if change not in author_entries:
                    (change_type, _) = next(iter(change.items()))
                    if change_type not in VALID_PREFIXES:
                        logging.critical('  {0}: Invalid prefix {1}'.format(fileName, change_type))
                        return
                    author_entries += [change]
                    new += 1
            all_changelog_entries[today][cl['author']] = author_entries
            if new > 0:
                logging.info('    Added {0} new changelog entries.'.format(new))

        if cl.get('delete-after', False):
            if os.path.isfile(fileName):
                if args.dryRun:
                    logging.warning('  Would delete {0} (delete-after set)...'.format(fileName))
                else:
                    del_after += [fileName]

        if args.dryRun:
            continue

        cl['changes'] = []
        with open(fileName, 'w') as f:
            yaml.dump(cl, f, default_flow_style=False)

    targetDir = os.path.dirname(args.targetFile)

    jenv = jinja2.Environment(
        extensions=['jinja2.ext.do'],  # Occasionally useful.
        loader=jinja2.FileSystemLoader('.'),
        autoescape=jinja2.select_autoescape(
            enabled_extensions=('htm', 'html'),
        ))
    tmpl = jenv.get_template(os.path.join(targetDir, 'templates', 'changelog.tmpl.htm'))


    remove_dates = []
    days_written = 0
    entries = collections.OrderedDict()
    for _date in sorted(all_changelog_entries.keys(), reverse=True):
        #entry_htm = '\n'
        #entry_htm += '\t\t\t<h2 class="date">{date}</h2>\n'.format(date=_date.strftime(dateformat))
        write_entry = False
        date_entries = collections.OrderedDict()
        for author in sorted(all_changelog_entries[_date].keys()):
            if len(all_changelog_entries[_date]) == 0:
                continue
            #author_htm = '\t\t\t<h3 class="author">{author} updated:</h3>\n'.format(author=author)
            #author_htm += '\t\t\t<ul class="changes bgimages16">\n'
            changes_added = []
            for (css_class, change) in (next(iter(e.items())) for e in all_changelog_entries[_date][author]):
                if change in changes_added:
                    continue
                write_entry = True
                changes_added += [change]
                #author_htm += '\t\t\t\t<li class="{css_class}">{change}</li>\n'.format(css_class=css_class, change=change.strip())
                if author not in date_entries:
                    date_entries[author] = []
                date_entries[author] += [(css_class, change)]
            #author_htm += '\t\t\t</ul>\n'
        if write_entry and days_written <= MAX_DATE_ENTRIES:
            entries[_date] = date_entries
            days_written += 1
        else:
            remove_dates.append(_date)

    with open(args.targetFile.replace('.htm', '.dry.htm') if args.dryRun else args.targetFile, 'w') as changelog:
        changelog.write(tmpl.render(ENTRIES=entries, DATEFORMAT=DATEFORMAT))

    for _date in remove_dates:
        del all_changelog_entries[_date]
        logging.info('Removing {} (old/invalid)'.format(_date))

    with open(changelog_cache, 'w') as f:
        cache_head = 'DO NOT EDIT THIS FILE BY HAND!  AUTOMATICALLY GENERATED BY ss13_genchangelog.py.'
        yaml.dump_all([cache_head, all_changelog_entries], f, default_flow_style=False)

    if len(del_after):
        print('Cleaning up...')
        for fileName in del_after:
            if os.path.isfile(fileName):
                print(' Deleting {0} (delete-after set)...'.format(fileName))
                os.remove(fileName)

if __name__ == '__main__':
    main()
