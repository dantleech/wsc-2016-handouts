#!/bin/bash
rm source/guide.md
cat source/*.md > source/guide.md
grip source/guide.md --export index.html
