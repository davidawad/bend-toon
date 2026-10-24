# Publishing bend-toon to BendHub

Nothing here has been run. A publish is public and permanent under BendHub's
terms (https://bend-lang.com/bendai/terms#s18), and `bend main.bend --publish
<name>@<version>` needs a login only David can do, so it waits for him.

## The command

From the repository root, on a clean checkout of the commit to release, after
`just ci` is green:

```
bend login                                   # once; opens a browser
bend main.bend --publish bend-toon@0.1.0.0
```

The version has **four** numbers. bend 2.0.38 reads `<name>@<version>` with the
pattern `^([a-z][a-z0-9-]{0,63})@(0|[1-9][0-9]*)(\.(0|[1-9][0-9]*)){3}$`, so the
`bend-toon@0.1.0` in the bead is rejected ("at four numbers like 1.0.0.0");
`0.1.0.0` is the same release.

Without a name, `bend main.bend --publish` publishes by hash only and the
package is imported as `0x<hash>/main.bend`; `bend link bend-toon@0.1.0.0 0x<hash>`
names it afterwards.

## What it prints, and the hash to expect

`--publish` lists the files, the license, and the package hash before it uploads.
The hash is a function of the published files alone, so it can be computed
without publishing: `sh scripts/pkg-hash` (it mirrors bend 2.0.38's
`cli_publish`: the sha256 of `"<sha256 of file> <path>\n"` for every file, paths
sorted, first 32 hex digits; checked against three packages cached in
`~/.bend/lib`, whose directory names are their hashes).

At the commit that last touched `main.bend`, `src/` or `LICENSE` (`a2a821e`):

```
files: 18, bytes: 92856
0x6c540016ee6a6235bbe7ce97d06ff2ba
```

`publishing 18 files, 92856 bytes, as 0x6c540016ee6a6235bbe7ce97d06ff2ba` must
show the same hash. If it does not, a published file changed since this was
written: rerun `sh scripts/pkg-hash` and trust that instead. (Edits to
README.md, docs/, tests/, LAWS.bend, PROOF.bend and `src/spec.bend` do not
change the hash: `main.bend` does not import them.)

The 18 files: `main.bend`, `LICENSE` (MIT; the first line is
`SPDX-License-Identifier: MIT`, which bend reads as the package license) and
`src/` `decode`, `dline`, `encode`, `entry`, `expand`, `fold`, `frame`, `hdr`,
`head`, `json`, `num`, `prim`, `rep`, `split`, `step`, `text` (`.bend`).

## After publishing

bend prints `import bend-toon@0.1.0.0/main.bend as Main` (use any alias; the
README uses `Toon`). To use it from cswap-bend:

```
import bend-toon@0.1.0.0/main.bend as Toon
```

and convert cswap's `Json` with the nine-arm map in the README ("The value
type"). Check from a scratch directory that the import resolves and
`Toon.encode(Toon.JNull{}, Toon.encode_default())` answers `"null"`.

A published hash cannot change. Any later edit to a published file is a new
version (`0.1.1.0`), and adding or changing `LICENSE` changes the hash too.
