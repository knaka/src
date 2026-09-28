# README.md

* [Markdown からコードの特定行へのリンク](./task.cmd 'set "ARG0=%~f0"')
* [./bin/cowsay.sh の特定行へのリンク](./bin/cowsay.sh "set -o nounset -o errexit")

# <a name=0d8322b></a>Foo Bar

これらは行ける。前半部はデフォのリンクになってしまうが、後半はデフォの管理外なので、正しく置き換えられている。

* [cowsay.sh にある “anchor”](./bin/cowsay.sh '498080f')

これダメなのなぜかと言うと、VSCode 的にその region が二重で link provide されるのだが、どちらが「上」になるかが一定でない（並列処理されるようで、どっちが上になるか一定しない）から [cowsay.sh にある “anchor”](./bin/cowsay.sh#:~:text=498080f)

* issue 出したがナシのつぶて — [`DocumentLink` click target is unpredictable when multiple providers return overlapping ranges — provider priority (score/isBuiltin/registration order) is not respected · Issue #336258 · microsoft/vscode](https://github.com/microsoft/vscode/issues/336258)

生での相対パスでもリンクできるようにした: ./bin/cowsay.sh#:~:text=498080f

これらは、そもそも Markdown preview が面倒見ないので、置き換えがうまく行くようだ。

* ./.source/hello.txt#line=1 # RFC 5147 0-base index
* ./.source/hello.txt#L=2 # GitHub style
* ./.source/hello.txt#hello # Anchor
* ./.source/hello.txt#:~:text=hoge-,world%20foo&text=bar # Text fragment

# うまく行かない

できるが、二重でリンク化されているぽいのと、preview でリンクにならない [foo](file://./.source/hello.txt#:~:text=world%20foo&text=bar)

[cowsay.sh にある “anchor”](./bin/cowsay.sh#:~:text=498080f)

file://./.source/hello.txt#hello # NG。置き換えされていない。標準のリンク化が優先されてしまうようだ

file://./.source/hello.txt#:~:text=world%20foo&text=bar # Text fragment。これ、何かがダブっているな。見ための “rangeGroup” は効いていないが、前半部は置き換えはされている。Markdown でこれを積極的に使う必要もないか。

余計な部分 `&text=bar` があれば、二重置き換えされているが、プレビューでリンクになるし、前半部はクリックできる。  のところは、おそらくデフォの previewer が置き換えている。 [foo](./.source/hello.txt#:~:text=world%20foo&text=bar)

これだけだとダメ [foo](./.source/hello.txt#:~:text=world%20foo)

これ行けるんだが [foo](./.source/hello.txt#hello)

これダメなのなぜ？ いや、文末のここなら行けたりするぞ？？ [cowsay.sh にある “anchor”](./bin/cowsay.sh#498080f)
