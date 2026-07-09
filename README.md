# MRzerocloud_m

MATLAB client for [tool-mr0sim-modal_http](../tool-mr0sim-modal_http): Pulseq `.seq` upload, async job polling, NPZ `(signal, ktraj)` download via the deployed Modal gateway.

Requires MATLAB R2019a+ (`matlab.net.http` for multipart upload).

## Setup

Add the package root to the MATLAB path:

```matlab
addpath('path/to/MRzerocloud_m');
```

## Quick start

```matlab
[signal, ktraj] = mr0.simulate('gre.seq');
```

With no `Config` argument, simulation uses the cached bifti phantom `user/numerical_brain_cropped_bifti` on the **t4** worker pool, with `res`/`affine` matching that phantom's native grid.

The gateway requires `res` and `affine` on every bifti job (server-side reslicing). A different FOV can be requested by setting both on the config struct, e.g. from AnyField metadata via `loadConfig`.

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
| `mr0.configure(...)` | Set Modal gateway URL, progress callback |
| `mr0.getModalUrl()` | Current Modal gateway URL |
| `mr0.loadConfig(source)` | Parse AnyField JSON metadata |
| `mr0.defaultConfig()` | Default cached phantom id and sim flags |
| `mr0.simulate(seqPath, ...)` | Blocking simulation → `(signal, ktraj)` |
| `mr0.stopSimulation()` | Cooperative abort during polling |
