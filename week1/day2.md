## User Administration Exercise

Discovered typo in GECOS field for primary account.

Investigated using:

```bash
grep michael /etc/passwd
```

Corrected account information using:

```bash
sudo chfn michael
```

Verified correction:

```bash
grep michael /etc/passwd
```

Corrected account information usingL:

```bash
sudo vipw
```

Result:

```text
michael:x:1000:1000:Michael:/home/michael:/bin/bash
```
