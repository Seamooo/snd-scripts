# Snd Scripts

A collections of scripts maintined via vcs

Some scripts are heavily based off existing work and have been credited where appropriate

This repository is structured such that all changes to code should be made under `src/`
and all built macros are maintained under `build/`

## Development

All commits should have a passing build and corresponding built macros accompanying them

To manage this there is a `mise.toml` file specifying tool versions, intended for use with
[mise](https://mise.jdx.dev), and a pre-commit hook made immediately available when running `npm install`

By default all lua files in `src/**` will be built into corresponding macros under `build/**`
unless prefixing files with `lib` e.g. `src/fatefarming.lua` will build but `src/libfatefarming.lua` will not,
it will instead be treated only has a potential library file for building other macros

Type annotations conformant to those expected by [lua-language-server](https://github.com/LuaLS/lua-language-server)
are mandatory, with any types being disallowed outside generic narrowing or stubbing

[StyLua](https://github.com/JohnnyMorganz/StyLua) is used as the formatter for this repository.
Note this is different to language-server's formatter, as such some configuration
is required to use StyLua with your editor if you wish to use `format-on-save` or other
editor format options

### Dev commands

for diagnostics:

```bash
npm run check
```

for building:

```bash
npm run build
```

for formatting:

```bash
npm run fmt
```