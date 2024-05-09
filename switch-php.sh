#!/bin/zsh  
  
# 检查是否安装了 Homebrew  
if ! command -v brew >/dev/null 2>&1; then  
    echo "Homebrew 没有安装。请先安装 Homebrew。"  
    exit 1  
fi  
  
# 检查是否传递了 PHP 版本作为参数  
if [ "$#" -ne 1 ]; then  
    echo "使用方法: $0 <php-version>"  
    echo "例如: $0 php@8.2"  
    exit 1  
fi  
  
PHP_VERSION=$1  
  
# 确保 PHP_VERSION 是以 'php@' 开头的  
if [[ ! $PHP_VERSION =~ ^php@[0-9]+\.[0-9]+$ ]]; then  
    echo "错误的 PHP 版本格式。请使用 'php@X.Y' 的格式。"  
    exit 1  
fi  
  
# 检查指定的 PHP 版本是否已安装  
if ! brew list --versions "$PHP_VERSION" >/dev/null 2>&1; then  
    echo "指定的 PHP 版本 $PHP_VERSION 没有安装。请先使用 Homebrew 安装它。"  
    echo "例如: brew install $PHP_VERSION"  
    exit 1  
fi 
  
# 停止当前链接的 PHP 版本的服务（Status是started）  
CURRENT_LINKED_PHP=$(brew services list | grep 'php@' | awk '/started/ {print $1}')  
if [ -n "$CURRENT_LINKED_PHP" ]; then  
    brew services stop "$CURRENT_LINKED_PHP" || true  
    brew unlink "$CURRENT_LINKED_PHP" || true  
    sed -i '' '/export PATH="\/opt\/homebrew\/opt\/'$CURRENT_LINKED_PHP'\/bin:$PATH"/d' ~/.zshrc
    sed -i '' '/export PATH="\/opt\/homebrew\/opt\/'$CURRENT_LINKED_PHP'\/sbin:$PATH"/d' ~/.zshrc
fi  
  
# 链接指定的 PHP 版本  
brew link --force "$PHP_VERSION"  
  
# 你可以根据需要启动新的 PHP 版本的服务  
brew services start "$PHP_VERSION"  
  
# 更新 PATH 变量  
echo "export PATH=\"/opt/homebrew/opt/$PHP_VERSION/bin:\$PATH\"" >> ~/.zshrc  
echo "export PATH=\"/opt/homebrew/opt/$PHP_VERSION/sbin:\$PATH\"" >> ~/.zshrc # 如果 PHP 有 sbin 目录的话  
  
# 加载新的 PATH 变量  
source ~/.zshrc  
  
# 检查 PHP 版本以确保切换成功  
php -v  
  
echo "已成功切换到 $PHP_VERSION"
