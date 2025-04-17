# Build Zig reference from source

A minimal set of files to build HTML [reference documentation](https://ziglang.org/documentation/0.14.0/) for the Zig programming language.

These files were extracted from the source tree of [Zig 0.14.0](https://github.com/ziglang/zig/tree/5ad91a646a753cc3eecd8751e61cf458dadd9ac4/). The `build.zig` file has been minimized.

Feel free to examine the `langref.html.in` template, modify it, and create your own documentation files in a hardcore, Zig-style way! :)

To build, run the command
```
zig build
```
and check the `zig_out` directory. This process takes some time because all examples in the `doc/langref` folder will be built, colorized, and their output placed inside the template file.
