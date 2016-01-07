# mod-dump
A command line application to produce compatibility dumps on plugins built off of the xEdit codebase.

## usage

`ModDump.exe "file path" -game`

- file path: a relative or absolute path to a .esp or .esm file.  You can also use a text document list of paths.
- game
  - fo4: Fallout 4
  - sk: Skyrim
  - ob: Oblivion
  - fnv: Fallout New Vegas
  - fo3: Fallout 3

## information to dump

- Filename
- File size
- File hash (CRC32)
- Masters
- Description
- Bash/Smash Tags
- Override records
  - FormID
- Errors
  - ITMs
  - ITPOs
  - UDRs
  - Invalid/Out of order subrecords
  - References that could not be resolved
  - Unexpected references
- Record counts
  - Number of records
  - Number of new records
  - Number of injected records
  - Number of override records
- Record groups
  - Group signature
  - Record count in group
  - Override record count in group