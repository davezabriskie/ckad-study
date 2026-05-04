# Vim Cheatsheet — CKAD Edition

> Goal: vim should be **invisible**. The exam tests Kubernetes, not vim.
> These are the only commands you need.

---

## First thing at exam start

```bash
echo "set expandtab ts=2 sw=2 nu ai" >> ~/.vimrc
```

| Setting | Why |
|---|---|
| `expandtab` | spaces instead of tabs — YAML silently fails on mixed indentation |
| `ts=2 sw=2` | 2-space indent to match Kubernetes convention |
| `nu` | line numbers |
| `ai` | autoindent — new lines inherit current indent level |

---

## The core (muscle memory required)

| Command | What it does |
|---|---|
| `/pattern` | jump to pattern — always faster than scrolling |
| `n` / `N` | next / previous match |
| `o` / `O` | new line below / above, enter insert mode |
| `A` | append at end of line |
| `I` | insert at start of line |
| `Esc` | back to normal mode |
| `>>` / `<<` | indent / unindent current line |
| `V` → `j/k` → `>` | visual select lines → indent block |
| `:wq` | save and quit |
| `:q!` | quit without saving — regenerate the scaffold |
| `u` | undo |

---

## Next tier (outsized return)

| Command | What it does |
|---|---|
| `.` | repeat last change — indent, add field, repeat down file |
| `gg` / `G` | top / bottom of file |
| `{` / `}` | jump between blank-line-separated blocks — fits YAML structure |
| `cc` | replace entire line |
| `C` | replace from cursor to end of line |
| `dG` | delete to end of file — nuke a bad scaffold without exiting |
| `diw` | delete inner word — fast renaming |
| `:%s/old/new/g` | find and replace all — rename a resource without hunting |

---

## The CKAD workflow in practice

```bash
# generate scaffold
kubectl create deployment api --image=nginx --dry-run=client -o yaml > deploy.yaml

# edit
vim deploy.yaml
```

Inside vim:
1. `/containers` → jump to the right section
2. `o` → new line, add your fields
3. `V` + select + `>` → fix any indentation
4. `:wq` → done

```bash
kubectl apply -f deploy.yaml
kubectl get pods -l app=api
```

---

## Safely ignore

Macros, registers, buffers, splits, tabs, `f`/`t` motions, plugins.
Diminishing returns for a 2-hour exam.

---

## Real bottleneck

Not vim. It's hesitating on **what YAML to add** or **which kubectl command to run**.
Vim just needs to stay out of the way.
