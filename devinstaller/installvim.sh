#/bin/bash

git clone -b v8.2.4649 https://github.com/vim/vim.git
cd vim 
./configure \
  --with-features=huge \
  --enable-multibyte \
  --enable-luainterp=yes \
  --enable-perlinterp=yes \
  --enable-cscope \
  --enable-pythoninterp=no  \
  --enable-python3interp=yes   \
  --enable-rubyinterp==yes   \
  --with-python3-command=python3  \
  --with-tlib=ncurses \
  --enable-terminal   \
  --prefix=/opt/vim

make -j 8 && make install 

cd .. 
rm -rf vim 
