# latex-inputlisting-generator

Including a set of listings from a project into LaTeX document can be a pain in the arse.

This script constructs `\lstinputlisting` tags for all required source files, complete with source language, caption and label parameters.

For example, running the script `./generate.sh -e java -d mycode/` on the directory structure:

```
mycode/
├── morecode
│   └── someothercode.java
└── mylovelycode.java
```

will produce:

```
\lstinputlisting[language=Java, label={lst:someothercode}, caption={someothercode.java}]{mycode/morecode/someothercode.java}
\lstinputlisting[language=Java, label={lst:mylovelycode}, caption={mylovelycode.java}]{mycode/mylovelycode.java}
```

These tags can then be dropped into your LaTeX document.

## Running the Script
The standard set of tools available out of the box on most distributions are used (`find`, `sort`, `awk`, ...).
However, please note that GNU `find` is required as the `-regextype` argument is not available in the BusyBox version.

### Working Directory
The script should be run from the same directory as the LaTeX document for the relative file paths to work correctly.

### Parameters
#### -o | Output to File [Optional]
The `-o` option writes the generated tags to a given file.
By default the tags are written to standard output.

#### -e | File Extensions [Required] 
A list of file extensions used to search for source files.
Can be a single extension `-e java` or multiple`-e "java sh py"`

#### -d | Source Directories [Required]
A list of directories containing the source files.

## Tests
[BATS](https://github.com/sstephenson/bats) is used to run the tests.

