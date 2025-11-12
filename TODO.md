# TODO: Filename Cleaning Feature

## Core Features
- [ ] strip leading/trailing whitespace 
- [ ] squish consecutive whitespaces 
- [ ] remove FilenameTags 
- [ ] from a user-defined list of FilenameTags 
  - [ ] from a file, one FilenameTag per line 
  - [ ] an ENV var
  - [ ] args passed into CLI
  - [ ] args passed into a method
- [ ] the ability to create a longbox settings yaml file (default: ~/.longbox/settings.yaml)
  - [ ] the ability to add/remove FilenameTags to/from that settings yaml file

## Notes
- FilenameTags are attribution markers in parentheses found in .cbr/.cbz/.cb* filenames
- NOT implementing metadata-based renaming yet - that's future work
- Focus on cleaning existing filenames first

## Implementation Plan
1. Create FilenameTag removal functionality
2. Add whitespace cleaning
3. Implement configuration sources (file, env, args)
4. Add settings file management