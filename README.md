# mod-picker
A web application which helps users to pick mods to use in Bethesda Games such as Skyrim and Fallout 4.

## TestReputation
A spike project written in Delphi to test the performance of a user-reputation network.  You can download a compiled build from the Releases tab.

## mod-dump
A command line application to produce compatibility dumps on plugins built off of the xEdit codebase.  The plan is to have it support the dumping of:

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
