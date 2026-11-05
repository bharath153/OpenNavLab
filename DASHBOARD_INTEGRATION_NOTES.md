# OpenNavLab Dashboard v1.0.2 — GitHub Integration Overlay

This ZIP is an overlay for the existing OpenNavLab repository.

Copy its contents into the repository root. It adds/replaces:

```text
README.md
dashboard/
docs/dashboard/
```

It does not replace `config/`, `examples/`, `src/`, or the existing research
results.

## Why the GitHub dashboard package differs from the standalone ZIP

The standalone dashboard ZIP contains large Phase 5/7B MAT fallbacks.

The GitHub overlay deliberately avoids duplicating those generated files. The
dashboard first uses the full `results/data/` MAT output when it exists locally.
If it does not, it falls back to a compact Phase 7B snapshot generated from the
real reference run plus a compact cross-phase metrics CSV.

Phase 7C and Phase 7D use the real repository CSV result artifacts.

## Final verification after copying

From `OpenNavLab/dashboard`:

```matlab
clear all
app = run_opennavlab_dashboard;
```

Then:

1. Evidence → **Run Dashboard Self-Test**
2. Confirm all checks pass.
3. Run:

```matlab
files = export_dashboard_screenshots(app);
```

4. Close the dashboard.
5. Verify:

```matlab
timerfindall('Name','OpenNavLab navigation playback')
```

returns an empty array.

Commit the generated PNG files under `docs/dashboard/screenshots/` after visual
inspection.


## v1.0.1 maintenance fix

MATLAB's `timer` object supports millisecond precision. The playback timer now
explicitly rounds its requested period to the nearest millisecond before
construction. This removes the harmless startup warning:

```text
Period property is limited to 1 millisecond precision.
Sub-millisecond precision will be ignored.
```

The playback behavior, research data, regression checks and evidence outputs are
otherwise unchanged from the validated v1.0 release.

## v1.0.2 documentation set

Adds User Guide, Architecture, Validation, Reproducibility, Screenshot Captions and Release Notes under `docs/dashboard/`.
