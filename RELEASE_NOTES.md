# Release notes

## 0.2.0

- Pre-flight `.seq` checks: Pulseq version **≤ 1.4.2**, file **≤ 20 000 lines**
- `mr0.version()` reads `VERSION` from package root
- Example renamed to `examples/load_gre_sim_recon.m`; bundled `examples/gre.seq`
- NPZ/NPY result parsing fixes (`ktraj` N×4, Java zip extract)
- Progress messages use **mr0-cloud** (no gateway URL in output)
- MATLAB package call fixes (`mr0.defaultConfig`, `FileProvider`, `matlab.net.URI`)

## 0.1.0

Initial simple version of MRzeroCloud_m:

- mr0-cloud client: simulate via `mr0.simulate`, default **t4** worker
- Single-slice bifti phantom (`user/numerical_brain_cropped_bifti`)
- Server **MRzeroCore 0.4.12**
- Pulseq `.seq` files from **pypulseq ≤ 1.4.2** only
- Example: `examples/load_gre_sim_recon.m` with `examples/gre.seq`
