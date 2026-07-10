# Release notes

## 1.0.1

_Package version now tracks the MRzeroCore version on mr0-cloud._

- Server **MRzeroCore 1.0.1** (was 0.4.12): Pulseq **1.5** via `pulseq_rs`
- Pre-flight `.seq` checks now allow Pulseq version **≤ 1.5.0** (was ≤ 1.4.2)
- Example `load_gre_sim_recon.m`: Cartesian recon uses **ifft2** for MRzeroCore 1.0 signal sign convention

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
