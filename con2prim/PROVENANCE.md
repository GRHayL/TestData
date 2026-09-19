# Hybrid Con2Prim fixture provenance

These are implementation-derived regression references, not independent
certification of the recovery algorithms. The source recipe below identifies
the producer without relying on a moving GRHayL branch.

## Exact producer source and environment

Start from GRHayL commit `01464c22e7d0883ecaa962abe21217b22d36a5df` and apply
[generator-source.patch](generator-source.patch). That patch contains every
numerically relevant producer change for this fixture update. The comparison
helper and reader repairs are consumer changes, not producer dependencies.

The producer used GCC `13.3.0-6ubuntu2~24.04.1`, glibc
`2.39-0ubuntu8.9`, Linux x86-64 little endian, and an AMD Ryzen 9 7950X.
The effective compile flags were:

```text
-Wall -std=c99 -march=native -fno-finite-math-only -O2 -g
```

HDF5 include/link flags were detected normally; this generator does not read an
EOS table. Configure and build in a disposable checkout of the producer source:

```sh
git apply /path/to/con2prim/generator-source.patch
CC=gcc ./configure --noomp --prefix="$PWD/install"
make tests datagen
mkdir generated
cd generated
LD_LIBRARY_PATH=../build/lib ../test/data_gen/unit_test_data_con2prim_multi_method_hybrid
```

Run the generator as a fresh process. It uses the C library's initial `rand()`
state, with no `srand()` call. The libc implementation and random-call order are
therefore part of the recipe. Separate executions in the stated environment
produced byte-identical files. Native code generation and math libraries can
change bytes on other machines; cross-compiler replay is numerical validation,
not a promise of bitwise regeneration on every CI runner.

## What changed and why

- Restore the existing parallel magnetic-field/momentum edge. Its previous
  oblique replacement concealed cancellation in the conservative limiter.
- Clamp the mathematically nonnegative magnetic numerator before calculating
  fluid energy. For the parallel edge, the limited momentum components are
  approximately `8.169043187546507e-14`.
- Restore symmetric input perturbations, `1 + 1e-14*randf(-1,1)`. Positive-only
  perturbations do not prevent cancellation in output sensitivity.
- Restore entropy evolution before the primitive-limits stage, independently
  of the last selected recovery method. This matches the existing consumer.
  Update its downstream conservative entropy consistently.

The metric/B-field input remains unchanged. Existing sampling and binary
layouts remain unchanged. The affected families are `apply_conservative_limits`,
`con2prim_multi_method_hybrid`, `enforce_primitive_limits_and_compute_u0`, and
`compute_conservs_and_Tmunu`. Publish these companions together.

## Evidence and limits

GCC 13.3 and Clang 18.1.3 replayed the affected families against this same
GCC-produced data. The existing hybrid failure suite and unchanged legacy
primitive/conservative comparisons also passed with the repaired consumers.
An independent long-double tensor calculation from stored primitive and metric
inputs found maximum norm-scaled differences of about `1.02e-15` for
conservatives and `9.64e-16` for stress energy. The entropy values agree with
`P/rho` for this Gamma=2 EOS to about `1.09e-16` relative.

These checks do not make the generator an independent inverse-solver oracle.
No ET legacy output is regenerated here. Existing ET induction gauge references
contain NaNs throughout the compared interior; strict finite-value comparisons
correctly reject them. They need an independent legacy producer, not substitution
with current GRHayL output.

The perturbed input stream is reproducible through the exact recipe above but
is not stored as a separate new fixture. No new test executable, sampling case,
or CI execution is introduced.
