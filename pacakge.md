# Packaging Python MCP Servers with Anthropic DXT

> **Purpose**: Guide to bundling a Python‑based Model Context Protocol (MCP) server inside an Anthropic **Desktop Extension (.dxt)** so it runs smoothly in Claude Desktop.

---

## 1  Python support in DXT

* Claude Desktop ships **without** an embedded Python runtime; only Node.js is bundled.
* A DXT extension can declare its server as `type: "python"`, but you must supply:

  * a **Python interpreter** (either present on the user’s system *or* packaged in the extension), and
  * all **required Python packages**.

---

## 2  Specifying the Python interpreter

| Scenario                        | Manifest `command` value                                                | Notes                                                          |
| ------------------------------- | ----------------------------------------------------------------------- | -------------------------------------------------------------- |
| Rely on system Python (Unix)    | `"python3"`                                                             | Avoid plain `python` to fix **ENOENT** on macOS/Linux.         |
| Rely on system Python (Windows) | `"python"`                                                              | Ensure user installed Python from python.org or Windows Store. |
| Ship your own venv              | `${__dirname}/server/venv/bin/python` (or `Scripts\\python.exe` on Win) | Make sure the binary is executable (**chmod +x**).             |
| Ship a frozen binary            | path to compiled exe                                                    | Use `server.type: "binary"`.                                   |

**Tip** – Use manifest overrides (`platforms`) if you need different commands for each OS.

---

## 3  Two ways to bundle dependencies

### A. `lib/` + `PYTHONPATH` (most portable)

1. Install your requirements into `server/lib/`:

   ```bash
   pip install -t server/lib -r requirements.txt
   ```
2. Add to `manifest.json`:

   ```json
   {
     "server": {
       "type": "python",
       "entry_point": "server/main.py",
       "mcp_config": {
         "command": "python3",
         "args": ["${__dirname}/server/main.py"],
         "env": {
           "PYTHONPATH": "${__dirname}/server/lib"
         }
       }
     }
   }
   ```
3. Benefits

   * Works across OSes (as long as packages are pure‑Python or you ship platform wheels).
   * Avoids execute‑permission issues.
   * Keeps `.dxt` size smaller than bundling an interpreter.

### B. Bundle a virtual environment (`server/venv/`)

1. Create the venv locally:

   ```bash
   python3 -m venv server/venv
   source server/venv/bin/activate
   pip install -r requirements.txt
   ```
2. Reference the venv’s Python:

   ```json
   "command": "${__dirname}/server/venv/bin/python"
   ```
3. Gotchas

   * Ensure `venv/bin/python` (or `Scripts/python.exe`) is executable – otherwise **EACCES** at launch.
   * Venvs aren’t cross‑platform; you may need separate `.dxt` builds per OS.
   * Larger package size (includes Python stdlib and binaries).

> **When to choose which?**
>
> * Use **lib + PYTHONPATH** if your audience likely has Python installed.
> * Use a **bundled venv** or frozen binary if you need absolute one‑click install with no external deps.

---

## 4  Example directory layout

```
my-extension.dxt
├── manifest.json
├── server/
│   ├── main.py
│   └── …
├── lib/           # ← if using approach A
└── venv/          # ← if using approach B (optional)
```

---

## 5  Troubleshooting cheatsheet

| Error                                        | Likely cause                                            | Fix                                               |
| -------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------- |
| `spawn python ENOENT`                        | Manifest points to `python`; no such binary in `$PATH`. | Use `python3` or full path.                       |
| `ModuleNotFoundError: No module named 'mcp'` | Dependencies not bundled.                               | Include package in `lib/` or venv.                |
| `spawn … EACCES`                             | Packaged interpreter not executable.                    | `chmod +x server/venv/bin/python` before packing. |

---

## 6  Best‑practice checklist

* [ ] Ship **all required packages** (including `mcp`).
* [ ] Test on a clean VM with no global installs.
* [ ] Use platform‑specific manifest overrides if interpreter paths differ.
* [ ] Keep `manifest.json` in repo so others can run `dxt pack`.
* [ ] Document any system prerequisites (Python ≥3.9) if you rely on system Python.

---

## 7  Further reading

* DXT spec & examples → [https://github.com/anthropics/dxt](https://github.com/anthropics/dxt)
* *File Manager (Python)* example (bundled `lib/`) → [`examples/file-manager-python`](https://github.com/anthropics/dxt/tree/main/examples/file-manager-python)
* MCP debugging guide → [https://modelcontextprotocol.io/docs/tools/debugging](https://modelcontextprotocol.io/docs/tools/debugging)

---

*Last updated 2025‑07‑01*
