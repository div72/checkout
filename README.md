# checkout
A basic cli utility to directly checkout PRs and branches on forks for GitHub.
## Installation
### From Source
[V](https://github.com/vlang/v) is required to compile checkout from source.
```shell
v -prod -o checkout .
cp ./checkout ~/.local/bin/checkout # so that checkout is invokable from everywhere
```
### From Binary
The binary for the latest release is [here](https://github.com/div72/checkout/releases/latest). It is recommended to place the binary to `~/.local/bin` for easier usage.
## Usage
```
USAGE: checkout <target>

target - a required parameter which can either be a branch on the local repository,
a GitHub PR number or a repository slug in {fork_owner}:{branch} format.

This program will automatically add remotes required and set relevant upstreams for
new branches checked-out from this program. Existing branches will not be affected.
```
## License
[GPL v3.0](/LICENSE).
