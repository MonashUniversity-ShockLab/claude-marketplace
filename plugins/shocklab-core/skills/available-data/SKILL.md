---
name: available-data
description: Find what data the ShockLab group already has (schlieren, acoustics, PIV, BOS, LES, DNS, shock tube, wind tunnel) for a given nozzle, flow, NPR, view or person, and WHERE it is stored on Market or Vault, from the dataset catalogue in Library_of_Shock_Lab/datasets/. Use when the user runs /available-data, or asks "do we have any schlieren of …", "is there acoustic data for … at NPR …", "where is <person>'s … data", "has anyone in the lab measured …", "which datasets use the ONR nozzle". Not for published literature (use /lit).
---

# /available-data

Answer "does the lab have data like this, and where is it?" from the group's dataset catalogue:
`datasets/` in the library repo (one page per dataset, searchable frontmatter), searched with
`tools/datasets.py`. The raw storage inventories behind it are on Market.

## 1. Find the library

Use `$SHOCKLAB_KNOWLEDGE` if set, else a `Library_of_Shock_Lab` folder in or next to the working
directory (as in the lab-knowledge skill). Pull it first so the catalogue is current:
`git -C <library> pull --ff-only -q` (if it fails because of local changes, carry on and say the
catalogue may be a little out of date). Python: any Python 3.8+ (`python`, or the base Anaconda
`python.exe`); the tools use only the standard library.

## 2. Turn the question into a search

Map the request onto `datasets.py find` filters (`python <library>/tools/datasets.py find --help`):

| user says | filter |
|---|---|
| schlieren / high-speed schlieren / shadowgraph-type imaging | `--technique schlieren` |
| acoustics, microphones, noise spectra | `--technique acoustics` |
| PIV, velocity fields | `--technique PIV` |
| BOS, tomographic BOS | `--technique BOS` |
| LES / DNS / simulation | `--technique LES` or `--technique DNS` |
| a nozzle ("ONR", "elliptical", "AR4", "chevron", "16 mm axisymmetric") | `--nozzle <word>` |
| a flow ("impinging", "twin", "crossflow", "retropropulsion", "shock tube") | `--flow <word>` or a free term |
| NPR 3.5 | `--npr 3.5` |
| Mach 0.9 / Mj 0.9 ("jet Mach") | `--mj 0.9` |
| acoustic Mach Ma 0.9 (Uj/a_amb) | `--ma 0.9` |
| a view ("minor axis") | `--view minor` |
| a person | `--who <name>` |
| a year | `--year 2023` |

Start specific; if nothing matches, drop the least important filter and say so (e.g. "nothing at
exactly NPR 3.5; these cover 3.4 and 3.6"). Run two or three searches if the question is broad.
For an NPR, a `listed` match means that NPR is recorded; `in range` means it lies inside a recorded
range ("2.1-6.0"), so it was probably but not certainly recorded: say which; `between steps`
means the set used a known grid that skips that value (give the nearest). NPR, Mj and Ma are
converted into each other (gamma 1.4, ideally expanded; Ma assumes an unheated jet unless the page
gives `ttr`), and the match says when it came through a conversion ("in range as Ma 0.835,
unheated assumed"): pass that on, since a conversion from Ma depends on the jet temperature. If
the user just says "Mach 0.9" for a jet, use `--mj` and say so.

## 3. Answer

For each matching dataset give, compactly:

- what it is (title, technique, nozzle, NPRs, view, date, who) and the catalogue page
  (`datasets/<page>.md`);
- **where it is**: every location, with its status. Give the path as the tool prints it: the UNC
  path, plus the drive path on this PC when the tool shows one. If the data is inside a zip, say
  which folder inside it.
- what processing exists (mats, mean, SPOD, POD, videos ...) and the DOI if published.

Flag location statuses that are not `verified` (`to-confirm`: the data was matched to a zip by
its position and name in the folder tree, nobody has looked inside, so say "probably in <zip>,
folder <in_zip>, to be confirmed"; `unverified`: from the old spreadsheet, not yet checked; `moved`/`not-found`: the recorded path no longer exists, give the candidates). Group
related datasets rather than repeating the same location.

**Vault is tape-backed.** Every file on Vault is an offline stub; opening one (copying, reading,
looking inside a `.zip` or `.mat`) recalls it from tape, which the storage admins want kept to
deliberate requests. So:

- never open, copy, hash or unzip anything on Vault yourself, and never list a zip's contents;
  to see inside an archived zip, use its saved file list if it has one (the location's
  `manifest`; search them all with `datasets.py manifest --grep REGEX`);
- listing Vault folders is safe, but the catalogue and inventories usually make it unnecessary;
- when the answer points at Vault, tell the user the data is on tape and that opening it starts a
  recall, so they can choose to request just what they need.

Market can be read freely.

## 4. When the catalogue has nothing

The catalogue may not cover everything. Search the raw storage inventories (lists of every folder
on Market and Vault, made without opening any file):

```
python <library>/tools/data_inventory.py grep <inventory> REGEX [REGEX ...]
```

The inventories are `<store>_<date>.csv.gz` in `Library_of_Shock_Lab\Data_Inventory\` on Market
(`$SHOCKLAB_DATA_INVENTORY` overrides); use the newest `market_*` and `vault_*`. Search with
words from folder names (`ONR`, `Schlieren`, `NPR_?3[._]5`, a person's name). Report candidate
folders clearly as **uncatalogued, identified from folder names only**, with sizes and file types,
and suggest who to ask (the top-level Market folder is usually the person's name).

If you find a real dataset this way, or the user tells you about one, offer to add a page: write
it to the format in `datasets/README.md`, run `datasets.py check` and `datasets.py build`, and
open a pull request to the library (members always by PR; the org's PR agent merges it).

If the user is about to archive data to Vault as a zip, remind them to save its file list first:
`datasets.py manifest <zip> --destination "vault\..."` (the README's "Before you archive" section).

## Don'ts

- Don't move, rename, edit or delete anything on Market or Vault; this skill only reads.
- Don't guess conditions that the page doesn't state; say they're unknown and who would know.
- Don't put the raw inventories, or long file listings from them, in the repo.
