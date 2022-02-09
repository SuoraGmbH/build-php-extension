# Develop, Build and Test PHP Extensions

This is a tool to develop, build and test PHP extensions in Docker containers.

## Installation

Clone this repository and add the `bin/` directory of this repository to your `$PATH`.

## Usage

Call the `build-php-extension` from the root directory of your extension source. The directory must contain
your `config.m4` file.

The `build-php-extension` command has multiple subcommands.

To configure and build your extension, run:

```shell
build-php-extension configure
```

To trigger a build, you can run:

```shell
build-php-extension build
```

And to run the tests, you need to execute:

```shell
build-php-extension test
```

You can specify the tests which should be executed as parameters to the test command. If you omit the list of tests, all
tests are run.

```shell
build-php-extension test tests/my_test_*.phpt
```

You can specify the minor PHP version which should be used, whether to enable thread-safety (`--zts`) and the build
mode (`--release` or `--debug`) as arguments to all commands:

```shell
build-php-extension --php-version 7.4 --release --zts build
```

The default is to disable thread safety and to build in debug mode.

To open an interactive shell inside a Docker container, you can execute:

```shell
build-php-extension shell
```

The `dist-clean` subcommand can be used to clean all generated files from the build directory:

```shell
build-php-extension dist-clean
```

Status information is stored by the tool in the file `.build-php-extension.state.ini` inside the source code of your
extension. You should add this file to your `.gitignore`.

## Rebuild Docker Image

When you first execute a command in one specific configuration, the Docker image for that configuration will
automatically be built. When you call commands with the same configuration later on, that Docker image will be reused.
You can manually rebuild the Docker image with the following command:

```shell
build-php-extension --php-version 8.0 --debug build-image
```

## Customization

You can customize the behavior of the build using various hooks. These are scripts that are sourced at the respective
steps of the build process. These are the available extension points:

- `build-hooks/pre-configure.sh`
- `build-hooks/post-configure.sh`
- `build-hooks/pre-build.sh`
- `build-hooks/post-build.sh`
- `build-hooks/pre-test.sh`
- `build-hooks/post-test.sh`
- `build-hooks/pre-clean-build-directory.sh`
- `build-hooks/post-clean-build-directory.sh`

If the file `build-hooks/configure` exists and is executable, it is executed instead of calling `./configure` directly.
This can be used to pass additional flags to `./configure`. All command-line-arguments that script receives, should be
forwarded to `./configure`:

```shell
#!/bin/sh

set -eu
./configure --my-special-configure-flag "${@}"
```
