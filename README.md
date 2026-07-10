# MRzeroCloud_m

**Version 1.0.1** — see [RELEASE_NOTES.md](RELEASE_NOTES.md).

MATLAB client for the **mr0-cloud** server: Pulseq `.seq` upload, sim job, download

Requires MATLAB R2019a+ (`matlab.net.http` for multipart upload).
Supports only **Pulseq sequences:** version **≤ 1.5.0**, **≤ 20 000 lines** (`.seq` files; checked before simulate)

## Server
- **MRzeroCore** on mr0-cloud: **1.0.1** (`pulseq_rs`, Pulseq 1.5). Signal uses the MRzeroCore 1.0 sign convention (complex conjugate vs pre-1.0); Cartesian recon clients should use **ifft**, not fft.


## Setup

Add the folder that **contains** `+mr0` (not `+mr0` itself):

```matlab
addpath('path/to/MRzeroCloud_m');
rehash path;   % if the package was already on path
```

## Quick start

```matlab
[signal, ktraj] = mr0.simulate('gre.seq');
```

Example with recon: `examples/load_gre_sim_recon.m` (uses `examples/gre.seq`).

With no `Config` argument, simulation uses the cached bifti phantom `user/numerical_brain_cropped_bifti` on the **t4** worker pool, with `res`/`affine` matching that phantom's native grid.

The server requires `res` and `affine` on every bifti job (server-side reslicing). A different FOV can be requested by setting both on the config struct, e.g. from AnyField metadata via `loadConfig`.

## Protocol config

```matlab
config = mr0.loadConfig(jsonText);   % AnyField metadata
[signal, ktraj] = mr0.simulate('gre.seq', 'Config', config);
```

Override the phantom id:

```matlab
config = mr0.defaultConfig();
config.phantom_bifti = 'user/my-phantom';
[signal, ktraj] = mr0.simulate('gre.seq', 'Config', config);
```

## Abort

```matlab
f = parfeval(@() mr0.simulate('gre.seq'), 0, signal, ktraj);
pause(2);
mr0.stopSimulation();
```

## API summary

| Function | Purpose |
|----------|---------|
| `mr0.version()` | Package version string |
| `mr0.configure(...)` | Override mr0-cloud URL, progress callback |
| `mr0.getModalUrl()` | Current mr0-cloud server URL |
| `mr0.loadConfig(source)` | Parse AnyField JSON metadata |
| `mr0.defaultConfig()` | Default cached phantom id and sim flags |
| `mr0.simulate(seqPath, ...)` | Blocking simulation → `(signal, ktraj)` |
| `mr0.stopSimulation()` | Cooperative abort during polling |
