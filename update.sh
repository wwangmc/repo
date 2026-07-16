#!/bin/bash
# 全量扫描 debs 目录，重新生成 Packages 索引
dpkg-scanpackages -m ./debs > Packages

echo "全量更新完成！"
bzip2 -c9 Packages > Packages.bz2
xz -c9 Packages > Packages.xz
xz -5fkev --format=lzma Packages > Packages.lzma
lz4 -c9 Packages > Packages.lz4
gzip -c9 Packages > Packages.gz
zstd -c19 Packages > Packages.zst && git add . 
echo "生成成功！"