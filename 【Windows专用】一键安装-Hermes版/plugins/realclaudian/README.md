# Claudian Hermes macOS launcher

Place `run-hermes` in your `hermes-agent` directory or keep it anywhere and set `HERMES_REPO`.

In Claudian settings:

- Enable Hermes: on
- Hermes launcher path: absolute path to `run-hermes`
- Environment Variables:

```text
HERMES_HOME=/Users/yourname/.hermes
```

Claudian appends `acp --accept-hooks`, so this launcher runs Hermes as:

```bash
hermes acp --accept-hooks
```

Make the launcher executable on macOS:

```bash
chmod +x run-hermes
```
