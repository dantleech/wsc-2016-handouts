#!/bin/bash
pandoc --from markdown_github -c css/buttondown.css --to html source/guide.md > index.html
