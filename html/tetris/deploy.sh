#!/bin/bash

BUCKET=s3://tetris.gdaws.co.uk

s3cmd put public/index.html $BUCKET/index.html \
    --acl-public \
    --reduced-redundancy


s3cmd put public/js/main.js.gz $BUCKET/js/main.js \
    --acl-public \
    --reduced-redundancy \
    --add-header "Cache-Control: max-age=31536000" \
    --add-header "Content-Encoding: gzip"

s3cmd put public/css/tetris.css $BUCKET/css/tetris.css \
    --acl-public \
    --reduced-redundancy \
    --add-header "Cache-Control: max-age=31536000"

s3cmd put public/favicon.ico $BUCKET/favicon.ico \
    --acl-public \
    --reduced-redundancy \
    --add-header "Cache-Control: max-age=31536000"

s3cmd sync public/img/ $BUCKET/img/ \
    --delete-removed \
    --acl-public \
    --reduced-redundancy \
    --add-header "Cache-Control: max-age=31536000"

s3cmd sync public/fonts/ $BUCKET/fonts/ \
    --delete-removed \
    --acl-public \
    --reduced-redundancy \
    --add-header "Cache-Control: max-age=31536000"

s3cmd sync public/sounds/ $BUCKET/sounds/ \
    --delete-removed \
    --acl-public \
    --reduced-redundancy \
    --add-header "Cache-Control: max-age=31536000"
