# Radiation M1 reference fixtures

This folder contains 14 gzip-compressed binary fixtures for GRHayL's Radiation
M1 unit tests. Each fixture stores paired baseline and perturbed inputs,
reference outputs computed by THC_M1, and comparison metadata. The complete set
occupies about 5.6 MB compressed (about 178 MB decompressed) and holds 123,702
records.

The fixture families are pointwise closure and moments, instantaneous sources,
stress energy, three Rusanov flux variants, constant and varying four-point
transport, and the Jthick scalar. These are library-level operation checks.
They do not establish host evolution or continuum equivalence.

## Contents

SHA-256 digests are of the decompressed payloads. Input and output counts are
scalars per record.

| Fixture | Operation | Policy | Records | In | Out | SHA-256 |
| --- | --- | --- | ---: | ---: | ---: | --- |
| `pointwise_closure_moments` | `pointwise_closure_moments` | `pointwise_a1_a2_v1` | 56 | 68 | 38 | `dd96fad7e6e9e1a6ca540c8ebd988146febb36e529246f245f259b3632262eb1` |
| `m1_thcm1_instantaneous_sources` | `instantaneous_interaction_sources` | `source_a1_a2_rate_normalized_v1` | 168 | 40 | 9 | `b9af5ec09baca2dd30caed4c84d543b7ba4efe26e0f508a6ed6f8b49f1fab9c0` |
| `stress_energy` | `stress_energy` | `strict_relative_2e-12_propagated_response_v1` | 1,024 | 21 | 10 | `ffbca306c3776a5f521cd80ed45b8073030781132b53416900d86f8cb4a66405` |
| `rusanov_neutrino` | `neutrino_rusanov_flux` | `strict_relative_2e-12_propagated_response_v1` | 1,024 | 54 | 5 | `e014eb07b458d452a4fed40e950410d295f51e1527220686d50b8d486077b42c` |
| `rusanov_neutrino_current` | `neutrino_rusanov_flux_current_v2` | `strict_relative_2e-12_propagated_response_current_v2` | 1,024 | 54 | 5 | `082ff615dd50f172d2d2ebce6e96dde618af5900848285c8551e2f183e937058` |
| `rusanov_generic` | `rusanov_flux` | `strict_relative_2e-12_propagated_response_v1` | 1,024 | 17 | 4 | `57373f4d845ced0ca66914184ff401e5d4407d8f1697daa895cacc2a12bfb7e7` |
| `transport_four_point_d0` | `neutrino_four_point_transport_flux` | `strict_relative_2e-12_propagated_response_v1` | 19,128 | 50 | 5 | `9ecf9dd7f1654c9903b91b09577fd72795ee908deadb02e6cc63553ccfd439f0` |
| `transport_four_point_d1` | `neutrino_four_point_transport_flux` | `strict_relative_2e-12_propagated_response_v1` | 19,128 | 50 | 5 | `817102fbbce232a47ca019b44eb8822c1832a5979e261a687dbe722ac75b31e8` |
| `transport_four_point_d2` | `neutrino_four_point_transport_flux` | `strict_relative_2e-12_propagated_response_v1` | 19,128 | 50 | 5 | `008124d5a188fc280573950c4a154e6d4e3eb056af4a021de54bdf4f626c0a8e` |
| `transport_four_point_varying_d0` | `neutrino_four_point_prepared_transport_flux` | `strict_relative_2e-12_propagated_response_v1` | 12,960 | 50 | 5 | `38d90af8712bbb5604ba6c1ab3268bea9ed0af4294f23baa8e8430683cfd0af5` |
| `transport_four_point_varying_d1` | `neutrino_four_point_prepared_transport_flux` | `strict_relative_2e-12_propagated_response_v1` | 12,960 | 50 | 5 | `584dc11db6f141da8d8a43c316f2c71293bfd500d9b27dcdbd18263913aa59b2` |
| `transport_four_point_varying_d2` | `neutrino_four_point_prepared_transport_flux` | `strict_relative_2e-12_propagated_response_v1` | 12,960 | 50 | 5 | `0114c1ffba59539d8e5f077c0528c108a57be1db74693aadd79915299a9f9067` |
| `transport_four_point_varying_controls` | `neutrino_four_point_prepared_transport_flux` | `strict_relative_2e-12_propagated_response_v1` | 23,112 | 50 | 5 | `1228631d5064e90dca2d610d8d69809f001438d24c3d2ed7070268b73220d9fb` |
| `jthick_thcm1` | `jthick` | `pointwise_a1_a2_v1` | 6 | 20 | 1 | `3e8ebdebbc94ac5a335d25dd0065c1722b47b297db061d710d0ffe4c36ab0615` |

The `d0`, `d1` and `d2` suffixes are the three direction shards. The
`transport_four_point_varying_controls` records have identical baseline and
perturbed inputs; they are fixed-input controls, not perturbation evidence.

## Producer

Every reference output is a recorded THC_M1 value from a fresh execution of
THC_M1 source snapshots over frozen baseline and perturbed inputs. The
pointwise, source and Jthick families use debug builds of the standalone offline
producers. Transport uses an optimized build with HDF5 disabled. Rusanov
extracts THC_M1's wave-speed and number-flux fragments, and stress energy uses
the compiled THC_M1 `assemble_rT` route. The original production receipts
identify GCC/G++ 13.3.

GRHayL builds captured during production are comparison clients, not the
reference producer. Current GRHayL output is never used as a stored expected
value. The captured THC_M1 snapshots carry no upstream revision (the campaign
records them as `unversioned`), so the sources are identified by the snapshots
themselves. The producer evidence holding them is kept outside this repository.

## Regeneration

A regeneration package, `radiation-m1-regeneration-pr112-v06`, rebuilds the
producers from the frozen sources, re-executes the recorded inputs, and compares
every newly produced payload byte for byte with the decompressed payloads above.
In the verification run all 14 payloads were identical. Exact agreement is
platform-specific: other CPUs, compilers or math libraries can
change the last bits, and the comparison never relaxes a tolerance or replaces a
reference.

The package has not yet been uploaded to a public release, so no download URL
or archive digest is listed here. Add them to this file when it is published.

## Licensing

The regeneration package is a mixed-license source and evidence bundle. It
retains the original GPL version 3 notices of the THC_M1 sources it contains
and the BSD 2-Clause notices of the GRHayL sources, and TestData's BSD 2-Clause
license does not relicense them. The fixture files in this folder contain
numerical values only.

## Consumption

GRHayL's `.github/prepare_m1_fixtures.sh SOURCE_DIR DEST_DIR` decompresses the
14 members into an existing empty destination directory. Its fixture readers
open the resulting `.bin` files. The tests read stored reference values and
recompute GRHayL outputs from the recorded inputs.

## Binary layout

The decompressed stream begins with the eight bytes `M1THCMB1`, followed by
length-prefixed `operation` and `policy` strings and the record count. Integers
are unsigned 64-bit little-endian values. Strings contain a byte length followed
by that many bytes, without a terminator. Vectors contain an element count
followed by IEEE 754 binary64 values in little-endian order.

Each record contains, in order:

1. Strings: `case_id`, `pair_id`, `origin`, `seed_id`, `family`, `perturbation`.
2. Integers: `sensitivity_start`, `sensitivity_count`.
3. Vectors: `baseline_input`, `perturbed_input`, `baseline_output`,
   `perturbed_output`, `normalization`.
4. Integers: `baseline_available`, `perturbed_available`, `baseline_status`,
   `perturbed_status`, `baseline_reference_status`, `perturbed_reference_status`.

There is no padding or trailing data. The layout is implemented by GRHayL's
`Unit_Tests/m1_helpers/m1_thcm1_fixture_utils.c`.
