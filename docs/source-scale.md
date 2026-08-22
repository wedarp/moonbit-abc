# Source scale evidence

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tools/count_moonbit_lines.ps1 -RequireMinimum 7000
```

Captured locally after formatting and interface generation:

```text
production_noncomment=8523 production_files=73 test_noncomment=977 test_files=52 total_noncomment=9500
```

The script counts non-empty MoonBit lines, excludes documentation comments, excludes `*_test.mbt` from production, and ignores `_build`/`.mooncakes`. It is kept in the repository so the number can be reproduced rather than inferred from a directory size.
