# README.md

* [Markdown からコードの特定行へのリンク](./task.cmd 'set "ARG0=%~f0"') (Powered by [HTML Related Links](https://marketplace.visualstudio.com/items?itemName=rioj7.html-related-links))

[cowsay.sh](./bin/cowsay.sh "set -o nounset -o errexit")

# <a name=0d8322b></a>Foo Bar

[cowsay.sh にある “anchor”](./bin/cowsay.sh '498080f')

生での相対パスでもリンクできるようにした: ./bin/cowsay.sh#:~:text=498080f

* ./.source/hello.txt#line=1 # RFC 5147 0-base index
* ./.source/hello.txt#L=2 # GitHub style
* ./.source/hello.txt#:~:text=hoge-,world%20foo # Text fragment
* file://./.source/hello.txt#hello # Anchor
* file://./.source/hello.txt#:~:text=world%20foo&text=bar # Text fragment
