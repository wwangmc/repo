#!/bin/bash
# 全量扫描 debs 目录，重新生成 Packages 索引
# macOS 沙箱限制，dpkg-scanpackages 需要 sudo 才能解包
sudo dpkg-scanpackages -m ./debs > Packages
sudo chown $(whoami):staff Packages

# 后处理：给缺少 Section 的包补充默认分类
awk '
BEGIN { RS=""; ORS="\n\n" }
{
    if ($0 ~ /^Package:/ && $0 !~ /\nSection:/) {
        if ($0 ~ /Package:.*install/i) {
            sub(/Description:/, "Section: 一键装机\nDescription:", $0)
        } else {
            sub(/Description:/, "Section: Tweaks\nDescription:", $0)
        }
    }
    print
}
' Packages > Packages.tmp && mv Packages.tmp Packages

echo "全量更新完成！"
bzip2 -c9 Packages > Packages.bz2
xz -c9 Packages > Packages.xz
xz -5fkev --format=lzma Packages > Packages.lzma
lz4 -c9 Packages > Packages.lz4
gzip -c9 Packages > Packages.gz
zstd -c19 Packages > Packages.zst && git add .
echo "生成成功！"