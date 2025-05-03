#!/bin/bash
# 1. 备份旧 Packages 文件
if [ -f "Packages" ]; then
    cp Packages Packages.old
fi

# 2. 生成临时新 Packages 文件
dpkg-scanpackages -m ./debs > Packages.new

# 3. 对比新旧文件，提取新增条目
if [ -f "Packages.old" ]; then
    # 找出 Packages.new 中有但 Packages.old 中没有的包名
    grep -F "Package: " Packages.new | while read -r pkg_line; do
        pkg_name=$(echo "$pkg_line" | cut -d' ' -f2)
        if ! grep -q "Package: $pkg_name" Packages.old; then
            # 提取该包的所有信息（从 Package: 到下一个空行）
            sed -n "/^Package: $pkg_name$/,/^$/p" Packages.new >> Packages
        fi
    done
else
    # 第一次运行，直接使用新文件
    mv Packages.new Packages
fi

# 4. 清理临时文件
rm -f Packages.old Packages.new

echo "增量更新完成！"
bzip2 -c9 Packages > Packages.bz2
xz -c9 Packages > Packages.xz
xz -5fkev --format=lzma Packages > Packages.lzma
lz4 -c9 Packages > Packages.lz4
gzip -c9 Packages > Packages.gz
zstd -c19 Packages > Packages.zst && git add . 
echo "生成成功！"