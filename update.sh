#!/bin/bash
rm Packages; rm Packages.gz; rm Packages.bz2;
dpkg-scanpackages debs /dev/null > Packages && tar zcvf Packages.gz Packages && bzip2 -k Packages Packages.bz2
git add .
