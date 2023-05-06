# `LoadUpTo` implicitly unloads GHC>=9.4
`LoadUpTo` seems to implicitly unload previously loaded modules when using `LoadUpTo`.

# Test result
## GHC 9.2.7
```bash
$ cabal run --with-compiler=ghc-9.2.7
Adding Foo as a target, and executing 'LoadAllTargets'..
Succeeded
[ModSummary {
    ms_hs_date = 2023-05-06 08:41:22.242506663 UTC
    ms_mod = Foo,
    ms_textual_imps = [(Nothing, Prelude)]
    ms_srcimps = []
 }]
Adding Bar as a target, and executing 'LoadUpTo m'..
Succeeded
[ModSummary {
    ms_hs_date = 2023-05-06 08:41:25.97055171 UTC
    ms_mod = Bar,
    ms_textual_imps = [(Nothing, Prelude)]
    ms_srcimps = []
 },
 ModSummary {
    ms_hs_date = 2023-05-06 08:41:22.242506663 UTC
    ms_mod = Foo,
    ms_textual_imps = [(Nothing, Prelude)]
    ms_srcimps = []
 }]
 ```

 ## GHC 9.4.5
```bash
Adding Foo as a target, and executing 'LoadAllTargets'..
Succeeded
[ModSummary {
    ms_hs_hash = 154c8207fb74c60096bf34e3cbe34208
    ms_mod = Foo,
    unit = main
    ms_textual_imps = [(, Prelude)]
    ms_srcimps = []
 }]
Adding Bar as a target, and executing 'LoadUpTo m'..
Succeeded
[ModSummary {
    ms_hs_hash = de95e3e1b4f2aa7eb0d820d0d04f78de
    ms_mod = Bar,
    unit = main
    ms_textual_imps = [(, Prelude)]
    ms_srcimps = []
 }]
 ```

# Test result summary
| GHC   | # in scope |
|-------|------------|
| 9.6.1 | 1          |
| 9.4.5 | 1          |
| 9.2.7 | 2          |
| older | 2          |