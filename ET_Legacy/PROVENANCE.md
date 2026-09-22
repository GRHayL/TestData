# ET legacy fixture provenance

## Cap-safe conservative-variable comparison

The four `ET_Legacy_conservs_{input,input_pert,output,output_pert}.bin`
files form one matched set. Publish them together. The normal GRHayL replay
reads `input`, `output`, and `output_pert`; historical IllinoisGRMHD reads
`input_pert` to generate `output_pert`. Do not combine either new input with
an older output. The `ET_Legacy_primitives_*` files, including their
`input_pert` companion, remain the unchanged matched baseline from TestData
revision `4172dd28c0c8b2fdf1872e7f411bb37ba52ea717`. The other four
ET-Legacy families are unchanged at that revision too.

The two inputs were produced by
`GRHayL/Unit_Tests/data_gen/unit_test_data_ET_Legacy_conservs.c`, starting
from GRHayL revision `36932846fbfaff63414055834b278f97165b3ce4` with
the paired PR's cap-safe generator edit. That edit leaves the random draw
sequence, spatial metric, thermodynamic fields, and magnetic fields alone.
It rescales the velocity relative to the ADM shift to target Lorentz factors
from 1.2 to 5 and aborts if the `W_max=10` limiter acts. The exact added
sampling logic, inserted after `ghl_compute_ADM_auxiliaries`, is:

```c
const double W_test = 1.2 + (5.0 - 1.2)*i/(npoints-1);
const double utU[3] = {
  vx[index] + metric_adm.betaU[0],
  vy[index] + metric_adm.betaU[1],
  vz[index] + metric_adm.betaU[2]
};
const double q = ghl_compute_vec2_from_vec3D(metric_adm.gammaDD, utU)
               * metric_adm.lapseinv2;
if(!isfinite(q) || q <= 0.0)
  ghl_error("Invalid randomized velocity norm in ET-Legacy conservs generator.\n");
const double q_target = 1.0 - 1.0/(W_test*W_test);
const double velocity_scale = sqrt(q_target/q);
vx[index] = utU[0]*velocity_scale - metric_adm.betaU[0];
vy[index] = utU[1]*velocity_scale - metric_adm.betaU[1];
vz[index] = utU[2]*velocity_scale - metric_adm.betaU[2];
```

The edit also checks `speed_limit` immediately after
`ghl_limit_v_and_compute_u0` and calls `ghl_error` if it is true. GCC 13.3.0
generated the stored inputs. The reviewed build used the HDF5-enabled
default configuration and `debug-opt` flags (`-O2 -g`). In a clean GRHayL
checkout with HDF5 available, configure before building the generator:

```sh
CC=gcc ./configure --buildtype=debug-opt
make test/data_gen/unit_test_data_ET_Legacy_conservs
```

Run that executable in a fresh working directory with the checkout's
`build/lib` on `LD_LIBRARY_PATH`. The unperturbed input starts with a
native `int` containing `80`, followed by 24 arrays of 6,400 doubles; the
perturbed input has the same arrays without the header. The built-in random
seed is `0` and the perturbation scale is `1e-14`.

The two outputs were produced by independent historical IllinoisGRMHD, not
GRHayL. Use `https://bitbucket.org/zach_etienne/wvuthorns.git`, branch
`GRHayLTestPatch`, revision `4f4c702e8a770372393ec42eb6985110be142ec9`.
Its `IllinoisGRMHD/src/driver_conserv_to_prims.C` routine
`GRHayL_conservs_test_data` reads both input streams and writes the
corresponding 20-array output streams. Use an Einstein Toolkit `ET_2026_05`
GetComponents checkout; the reviewed manifest revision was
`427fa3934ec42c0b2b0ef6340e94a7c9ba4b6ac3`. Stage
[`conservs-legacy-fixture.th`](../ETK_IGM_files/conservs-legacy-fixture.th)
as `Cactus/thornlists/legacy-fixture.th`. Link that historical repository's
`IllinoisGRMHD`, `ID_converter_ILGRMHD`, and `Convert_to_HydroBase` thorns
under `Cactus/arrangements/LegacyFixture/`. The thorn list does not include
GRHayL. Do not apply `ETK_IGM_files/IGM_unit_test_PatchFile.0cb4d23`:
the historical branch already has these fixture entry points, and that
patch contains unrelated experimental changes.

The reviewed build used the following command from the Cactus root; machine
and simulation paths may be adapted to the host without changing the thorn
list or producer source:

```sh
simfactory/bin/sim build --machine cc --basedir=/path/to/simulations \
  --thornlist=thornlists/legacy-fixture.th -j8
```

Stage all six ET-Legacy families' `input` and `input_pert` files in one fresh
working directory. Use these two new conservs inputs and the five unchanged
families' inputs from revision `4172dd28c0c8b2fdf1872e7f411bb37ba52ea717`.
Run the Cactus executable from that working directory with
[`conservs-GRHayL_test.par`](../ETK_IGM_files/conservs-GRHayL_test.par):

```sh
OMP_NUM_THREADS=2 /path/to/Cactus/exe/cactus_sim \
  /path/to/TestData/ETK_IGM_files/conservs-GRHayL_test.par
```

The parameter file is historical `GRHayL_test.par` with only
`Cactus::cctk_itlast = 0` added. Both new conservs outputs must match the
published files byte-for-byte. A second run with `OMP_NUM_THREADS=1` matched
both outputs byte-for-byte in the reviewed environment. Run an old-input
control using all six families' inputs from revision `4172dd28...`; its
twelve outputs matched that revision byte-for-byte. With only conservs
inputs replaced, all five other families' outputs still matched the old
revision. A GRHayL replay using new conservs input with old conservs outputs
failed at the first row; this confirms stale-output mixing is detectable.

The reviewed binary64 states have independently recomputed maximum
`q = gamma_ij(v^i+beta^i)(v^j+beta^j)/alpha^2` of
`0.960000000000000252` for input and `0.960000000000016831` for
`input_pert`, below the `W_max=10` cap at `q=0.99`. All input and output
doubles are finite. Local GCC 13 and Clang 18 GRHayL replays passed all six
ET-Legacy families with this matched mixture. These local checks do not
replace the supported remote compiler/OS CI matrix. This compatibility
fixture is not a limiter-boundary oracle; direct Core tests cover that branch.

## Induction gauge-RHS comparison

The induction gauge-RHS outputs are independent legacy references. They are
generated by the IllinoisGRMHD test harness on the public `GRHayLTestPatch`
branch of `zach_etienne/wvuthorns`, at revision
`4f4c702e8a770372393ec42eb6985110be142ec9`.

Run this command from the TestData checkout:

```sh
sh ETK_IGM_files/generate_induction_legacy_outputs.sh
```

The script compiles the original
`Lorenz_psi6phi_rhs__add_gauge_terms_to_A_i_rhs.C` producer directly. Its small
standalone shim replaces only Cactus types, logging, and scheduling. It keeps
the legacy arithmetic and loop bounds unchanged and sets `damp_lorenz` to
`0.1`, matching both the GRHayL replay and the legacy `magnetizedTOV.par`.

Both the unperturbed and perturbed outputs are produced from their existing
input streams. GCC and Clang generation must be byte-identical when both
compilers are available. The stored outer-grid poison values are intentional;
the legacy producer and GRHayL replay compare only the initialized interior.

The input streams are produced by
`Unit_Tests/data_gen/unit_test_data_ET_Legacy_induction_gauge_rhs.c` in GRHayL.
Their Gaussian coordinates use floating-point grid spacing, so the checked
interior retains the intended spatial variation. Regenerate both inputs before
running the independent output generator whenever that input definition changes.

These outputs replace invalid files whose compared interiors contained only
non-finite values. They are not generated from GRHayL and therefore remain an
independent compatibility oracle.
