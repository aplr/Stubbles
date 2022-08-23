#!/bin/sh

swift package --allow-writing-to-directory ./docs \
    generate-documentation --target Stubbles \
    --disable-indexing \
    --transform-for-static-hosting \
    --output-path ./docs