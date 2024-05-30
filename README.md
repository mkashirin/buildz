# Buildz

Buildz is a Zig toolchain showcase for different types of linking, compiling 
and installing static and dynamic libraries and artifacts.

## Showcases

The build script includes the following showcases (building):
* Static library from Zig source code;
* Dynamic (shared) library from Zig source code;
* Executable from Zig source code and linking upmentioned libraries to it;
* Executable from C source code with the C standard library linked to it;
* Unit tests for Zig source code.

The script also allows for command line arguments passage.

The code for both static and shared libraries can be found in the files 
"static.zig" and "shared.zig" correspondingly. The `export` keyword must be
provided in oreder for function to be exported. Then the `extern` keyword is 
used to define a signature of a function to be imported from a library.

## Usage

In order to see the output of the build script, you will need to run the 
following command (assuming you are in the working directrory with the project
and have Zig installed on your machine):
```bash
zig build
```

You can additionally pass `buildz`, `buildc`, `test` or all of them at once 
to run the corresponding steps described in the build script. For example, 
to run the executable produced by Zig source code run the line below:
```bash
zig build buildz
```

Reed the comments in the source code files in order to learn more on how this 
amazing build system actually works!

## Zig version

All the code in this repo has been executed using Zig version 0.12.0.
